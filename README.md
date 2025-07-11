# Satisfactory Dedicated Server Utilities
Quality of Life utilities for Satisfactory Dedicated Servers

## List of Utilities
* [DownloadSaveGame](#1-downloadsavegame)
* [RestartServer](#2-restartserver)

### 1. DownloadSaveGame

#### What this script does?
It remotely connects to your dedicated server, and using the HTTPS API it generates a list of your most recent save games for each session name that you have. From that list you enter the corresponding session name and corresponding save game will be downloaded to your computer.

#### Why would you ever use this?
I often like to upload my save in SCIM to view statistics and other related things. Though perhaps you just want a way to download a copy of your save without having to remote desktop into the server.

#### Possible Limitations
I have only tested this on my self hosted dedicated server. For rented 3rd party dedicated servers, in theory as long as they expose the HTTPS API then my script should work with them as well.

#### Table of Contents
* [Step 1: Enable HTTPS API.](#1-1-step-1-enable-https-api).
* [Step 2: Get DownloadSaveGame GitHub files.](#1-1-step-2-get-downloadsavegame-github-files)
* [Step 3: Create shortcut to run script.](#1-1-step-3-create-shortcut-to-run-script)
* [Step 4: Running the script.](#1-1-step-4-running-the-script)

#### 1.1 Step 1: Enable HTTPS API.
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

#### 1.1 Step 2: Get DownloadSaveGame GitHub files.
Download all files located in the DownloadSaveGame folder from GitHub.

#### 1.1 Step 3: Create shortcut to your script.
Out of the box PowerShell scripts cannot be run without elevated privileges. We are not going to open up all PowerShell scripts to be run on your computer, just this individual script. To do this we will create a shortcut to the script and then in the target input field we will add the little magic code to make it run.

1. Right-click on your script and select Properties.
2. Modify the Target input field as follows.
   - `powershell.exe -ExecutionPolicy Bypass -File "C:\PATH\TO\SCRIPT\DownloadSaveGame.ps1"`

#### 1.1 Step 4: Running the script.
Double click the shortcut that you just created.


### 2. RestartServer

#### What this script does?
1. Ability to set more than one dedicated server restart in a day.
2. Ability to trigger a save through the API.
3. Autostart on computer reboot.

First off, this isn't a guide to set up your own dedicated server, for that you can follow the [Dedicated servers - Official Satisfactory Wiki](https://satisfactory.wiki.gg/wiki/Dedicated_servers). I ended up setting up my server using SteamCMD.

The only reason I decided to give my dedicated server a power up was because every now and then the FactoryServer.exe would consume 90% or higher CPU usage for no reason at all. Restarting the server session would resolve this, but I prefer to automate tasks such as this. As such I set out with the goal to restart the server session every 6 hours.

Initial research into this involved using NSSM as a service, but I didn't want to go this route.

#### Table of Contents
1. Step 1: Creating the restart script.
2. Step 2: Enable the HTTPS API.
3. Step 3: Grab files from GitHub.
4. Step 4: Setup Task Scheduler.
