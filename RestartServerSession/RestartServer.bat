@echo off

set "steamdir=J:\Apps\steamcmd"					:: Path to your SteamCMD folder.
set "username=SteamUsername"					:: You could probably login anonymously, but I chose to use my credentials.
set "game=Satisfactory"
set appid=1690800
set "appexe=FactoryServer.exe"
set "installdir=SatisfactoryDedicatedServer"	:: The folder which your Satisfactory Dedicated Server is installed at in the SteamCMD apps.
set "params="									:: Optional parameters that can be passed to SteamCMD.

:: Stop the dedicated server (if running)
taskkill /IM FactoryServer.exe /F
taskkill /IM FactoryServer-Win64-Shipping-Cmd.exe /F

:: Wait a few seconds; I'm using 10 seconds, but 3-5 seconds is probably sufficient.
timeout /t 10

:: Update server via SteamCMD (optional)
%steamdir%\steamcmd.exe +login %username% +app_update %appid% +quit
:: Force Install method to ensure game is up to date, in case game is not updating.
::%steamdir%\steamcmd.exe +force_install_dir %steamdir%\steamapps\common\%installdir% +login %username% +app_update %appid% +quit

:: Start the server again
start %steamdir%\steamapps\common\%installdir%\%appexe% %params% -log -unattended