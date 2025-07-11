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

Set-Location -Path $PSScriptRoot # Set working directory to location of PS script.


# === Config ===

$serverIP = "127.0.0.1" # Loopback IP Address.
$port = 7777
$uri = "https://{0}:{1}/api/v1" -f $serverIP, $port
$password = "admin password" # Administrator password for dedicated server, not admin password for server.
$maxSaves = 3 # Max number autosaves created by restart script.
$counterFolder = "C:\PATH\TO\Satisfactory\Utilities\RestartServerSession\Counters" # Folder location to store session save counters.
$restartPath = "C:\PATH\TO\Satisfactory\Utilities\RestartServerSession\RestartServer.bat" # Location to RestartServer.bat
$sleepDelay = 5 # Optional: small delay after save


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

function SaveGame {
	param(
		[string]$uri,
		[Hashtable]$headers,
		[string]$sessionName,
		[int]$saveIndex
	)
	$targetSaveName = "{0}_ScheduledRestartSave_{1}" -f $sessionName, $saveIndex
	
	$saveBody = @{
		function = "SaveGame"
		data = @{
			SaveName = $targetSaveName
		}
	} | ConvertTo-Json -Depth 3
	
	try {
		$response = Invoke-RestMethod -Uri $uri `
			-Method Post `
			-Headers $headers `
			-Body $saveBody `
			-ContentType "application/json"
	} catch {
		EndScript -msg "Failed to save game."
	}
}

function GetAndIncrementSaveIndex {
    param(
        [string]$counterFolder,
        [string]$sessionName,
        [int]$maxSaves
    )
	
    $counterPath = "{0}\{1}_SaveCounter.txt" -f $counterFolder, $sessionName
	
    if (-not (Test-Path $counterPath)) {
        Set-Content -Path $counterPath -Value "1" -Encoding UTF8
    }
	
    $saveIndex = Get-Content $counterPath | ForEach-Object { [int]$_ }
    $next = $saveIndex % $maxSaves + 1
    Set-Content -Path $counterPath -Value $next -Encoding UTF8
	
    return $saveIndex
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
    EndScript -msg "Session enumeration failed. Response is null."
}

# === Get active session name. ===

$sessionName = GetSessionName -sessionData $sessionResponse

# === Read and increment the counter. ===

$saveIndex = GetAndIncrementSaveIndex -counterFolder $counterFolder -sessionName $sessionName -maxSaves $maxSaves

# === Save the current session. ===

SaveGame -uri $uri -headers $headers -sessionName $sessionName -saveIndex $saveIndex

# === Optional delay before restarting dedicated server session. ===

Start-Sleep -Seconds $sleepDelay

# === Restart the Dedicated Server session ===

if (-not (Test-Path $restartPath)) {
	$message = "Restart path not found: {0}" -f $restartPath
    EndScript -msg $message
}

& $restartPath