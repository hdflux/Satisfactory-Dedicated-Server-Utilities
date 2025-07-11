# DownloadSaveGame [Back to Home](../README.md#satisfactory-dedicated-server-utilities)

## What this script does?

It remotely connects to your dedicated server, and using the HTTPS API it generates a list of your most recent save games for each session name that you have. From that list you enter the corresponding session name and corresponding save game will be downloaded to your computer.

## Why would you ever use this?

I often like to upload my save in SCIM to view statistics and other related things. Though perhaps you just want a way to download a copy of your save without having to remote desktop into the server.

## Possible Limitations

I have only tested this on my self hosted dedicated server. For rented 3rd party dedicated servers, in theory as long as they expose the HTTPS API then my script should work with them as well.

## Table of Contents
* [Step 1: Enable HTTPS API.](#step-1-enable-https-api).
* [Step 2: Get DownloadSaveGame GitHub files.](#step-2-get-downloadsavegame-github-files)
* [Step 3: Create shortcut to run script.](#step-3-create-shortcut-to-run-script)
* [Step 4: Running the script.](#step-4-running-the-script)

### Step 1: Enable HTTPS API.

Satisfactory’s dedicated server exposes a secure API that can:
* Trigger saves
* Query player count
* Manage sessions

We want the ability to retrieve sessions and download saves.

1. Open Game.ini (usually in FactoryGame\Saved\Config\WindowsServer\).
2. Add or confirm the following:
```
[/Script/Engine.GameSession]
bEnableWebServer=True
```
3. Restart the server session to apply changes.

### Step 2: Get DownloadSaveGame GitHub files.

Download DownloadSaveGame.ps1.
_If you plan using some of my other utilities then I recommend keeping the GitHub folder structure intact._

### Step 3: Create shortcut to run script.

Out of the box PowerShell scripts cannot be run without elevated privileges. We are not going to open up all PowerShell scripts to be run on your computer, just this individual script. To do this we will create a shortcut to the script and then in the target input field we will add the little magic code to make it run.

1. Right-click on your script and select Properties.
2. Modify the Target input field as follows.
   - `powershell.exe -ExecutionPolicy Bypass -File "C:\PATH\TO\SCRIPT\DownloadSaveGame.ps1"`

### Step 4: Running the script.

Double click the shortcut that you just created.
