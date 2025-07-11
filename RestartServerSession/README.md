# RestartServerSession [Back to Home](../README.md#satisfactory-dedicated-server-utilities)

## What this script does?

1. Ability to set more than one dedicated server restart in a day.
2. Ability to trigger a save through the API.
3. Autostart on computer reboot.

First off, this isn't a guide to set up your own dedicated server, for that you can follow the [Dedicated servers - Official Satisfactory Wiki](https://satisfactory.wiki.gg/wiki/Dedicated_servers). I ended up setting up my server using SteamCMD.

The only reason I decided to give my dedicated server a power up was because every now and then the FactoryServer.exe would consume 90% or higher CPU usage for no reason at all. Restarting the server session would resolve this, but I prefer to automate tasks such as this. As such I set out with the goal to restart the server session every 6 hours.

Initial research into this involved using NSSM as a service, but I didn't want to go this route.

## Table of Contents
* [Step 1: Get RestartServer GitHub files.](#step-1-get-restartserver-github-files)
* [Step 2: Enable HTTPS API.](#step-2-enable-https-api).
* [Step 3: Setup Task Scheduler.](#step-3-setup-task-scheduler)

### Step 1: Get RestartServer GitHub files.

1. Download RestartServer.bat.
   - Technically you can run SteamCMD anonymously, but I chose to use my Stean user credentials.
2. Download SaveGame.ps1.
   - The purpose of this script is to communicate with the dedicated server API, trigger a save followed by restarting the server session.
_If you plan using some of my other utilities then I recommend keeping the GitHub folder structure intact._

### Step 2: Enable HTTPS API.

Satisfactory’s dedicated server exposes a secure API that can:
* Trigger saves
* Query player count
* Manage sessions

We want the ability to trigger saves.

1. Open Game.ini (usually in FactoryGame\Saved\Config\WindowsServer\).
2. Add or confirm the following:
```
[/Script/Engine.GameSession]
bEnableWebServer=True
```
3. Restart the server session to apply changes.

### Step 3: Setup Task Scheduler.

1. Press Windows + R to open up your Run Command...
2. Type taskschd.msc and hit the Enter key.
3. Right-click in the blank space of the list of tasks and Create a Basic Task.
4. Give your task a name such as Restart Factory Server.
5. Under the General tab enable Run whether user is logged in or not.
6. I also choose Windows 10 for what it is configured to run under.
7. For the Triggers tab I created four triggers.
   1. Startup.
      1. Set Begin the task to run At Startup.
      2. Delay task for 3 minutes.
      3. Enabled.
   2. On a Schedule.
      1. Daily at 6 AM.
      2. Recur every 1 days.
      3. Enabled.
   3. On a Schedule.
      1. Daily at 12 PM.
      2. Recur every 1 days.
      3. Enabled.
   4. On a Schedule.
      1. Daily at 6 PM.
      2. Recur every 1 days.
      3. Enabled.
   5. We don't need a task to run as 12 AM since the dedicated server by default restarts daily at this time.
8. Under the Actions tab create a new action.
   1. Set it to Start a program.
   2. For the program just type powershell.exe.
   3. For arguments type
      - `-ExecutionPolicy Bypass -File "C:\Development\Satisfactory\Utilities\DownloadSaveGame\SaveGame.ps1"`
      - Remember to change the path to the location of the PowerShell script we created earlier.
9. Under the Settings tab;
    1. Enable Allow task to be run on demand.
    2. Stop the task if it runs longer than 4 hours.
    3. Enable If the running task does not end when requested, force it to stop.
10. Save the new task that we just created.
11. Optionally you could right-click on the task and try running it on demand to ensure that everything is functioning as expected.

That's it! You now have a dedicated server that saves and restarts its session every 6 hours. You can modify the instructions to run less or more frequently as desired.
