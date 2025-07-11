Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;

public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint,
        X509Certificate certificate,
        WebRequest request,
        int certificateProblem) {
        return true;
    }
}
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

cls

Set-Location -Path $PSScriptRoot


# === Config ===

$serverIP  = "192.168.1.54" # IP Address of your dedicated server.
$port      = 7777
$uri   = "https://{0}:{1}/api/v1" -f $serverIP, $port
$password  = "admin password" # Administrator password for your dedicated server, not the admin password for the server itself.


# === Functions ===

function Authenticate {
	param(
		[string]$uri,
		[string]$password
	)
	
	$loginBody = @{
		function = "PasswordLogin"
		data = @{
			Password = $password
			MinimumPrivilegeLevel = "Administrator"
		}
	} | ConvertTo-Json -Depth 3
	
	try {
		$response = Invoke-RestMethod -Uri $uri `
			-Method Post `
			-Body $loginBody `
			-ContentType "application/json"
	} catch {
		EndScript -msg "Failed to authenticate."
	}

	return $response.data.authenticationToken
}

function GetSessionData {
	param(
		[string]$uri,
		[Hashtable]$headers
	)
	
	$sessionBody = @{
		function = "EnumerateSessions"
		data = @{}
	} | ConvertTo-Json -Depth 3
	
	try {
		$response = Invoke-RestMethod -Uri $uri `
			-Method Post `
			-Headers $headers `
			-Body $sessionBody `
			-ContentType "application/json"
	} catch {
		EndScript -msg "Failed to retrieve sessions: $_"
	}
	
	return $response
}

function GetSessionName {
    param(
        [PSObject]$sessionData
    )
	
    $sessionIndex = $sessionData.data.currentSessionIndex
	
	if ($null -eq $sessionData.data.sessions[$sessionIndex]) {
		EndScript -msg "No active session found at index $sessionIndex"
	}
	
	$session = $sessionData.data.sessions[$sessionIndex]
	$sessionName = $session.sessionName
	
	if (-not $sessionName) {
		EndScript -msg "Session name is empty"
	}
	
    return $sessionName
}

function DownloadSave {
	param(
		[string]$uri,
		[Hashtable]$headers,
		[string]$targetSession,
		[string]$saveName
	)
	$downloadBody = @{
		function = "DownloadSaveGame"
		data = @{
			SessionName = $targetSession
			SaveName    = $saveName
		}
	} | ConvertTo-Json -Depth 3
	
	$outFolder = "SaveGames"
	if (-not (Test-Path $outFolder)) {
		New-Item -Path $outFolder -ItemType Directory | Out-Null
	}
	$outFileName = "{0}\{1}.sav" -f $outFolder, $saveName
	
	Invoke-RestMethod -Uri $uri `
		-Method Post `
		-Headers $headers `
		-Body $downloadBody `
		-ContentType "application/json" `
		-OutFile $outFileName
}

function ShowSessions {
	param(
		[PSObject]$sessionData
	)
	
	Write-Host ("Available sessions:")
	
	foreach ($session in $sessionData.sessions) {
		$recentSave = $session.saveHeaders[0]

		if ($recentSave) {
			$sessionName = $recentSave.sessionName
			$saveName    = $recentSave.saveName
			$modified    = $recentSave.saveDateTime
			Write-Host ("- SessionName = {0}; SaveName = {1}; LastModified = {2}" -f $sessionName, $saveName, $modified)
		}
	}
}

function EndScript {
	param(
		[string]$msg
	)
	
	if ($msg) {
		Write-Error ($msg)
	}
	
	Read-Host "Press [Enter] to close console"
	
	exit
}


# === Authenticate. ===

$token = Authenticate -uri $uri -password $password

if (-not $token) {
	EndScript -msg "Authentication failed. Token is null."
}

# === Create headers. ===

$authHeader = "Bearer {0}" -f $token
$headers = @{ Authorization = $authHeader }

# === Get session data. ===

$sessionResponse = GetSessionData -uri $uri -headers $headers

if (-not $sessionResponse) {
	EndScript -msg "Fetching session data failed. Response is null."
}

# === Display session names and pick one. ===

#Write-Host ($sessionResponse.data | ConvertTo-Json -Depth 10)
ShowSessions -sessionData $sessionResponse.data

$targetSession = Read-Host "Enter the session name you'd like to filter by."

# === Filter desired session. ===

$matchingSession = $sessionResponse.data.sessions | Where-Object {
    $_.sessionName -eq $targetSession
}

if (!$matchingSession) {
	$message = "No session found with name '{0}'." -f $targetSession
	EndScript -msg $message
}

# === Download the session save game. ===

$saveName = $matchingSession.saveHeaders[0].saveName

Write-Host ("Latest save in session '{0}': {1}.sav" -f $targetSession, $saveName)

DownloadSave -uri $uri -headers $headers -targetSession $targetSession -saveName $saveName

Write-Host ("Save game downloaded: SaveGames\{0}.sav" -f $saveName)

# === Keep console open to read output. ===

EndScript