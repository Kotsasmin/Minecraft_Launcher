@echo off
color f
mode con:cols=80 lines=25
setlocal enabledelayedexpansion
echo Loading...
set "launcherName=Minecraft Launcher"
set "launcherVersion=0.0.0.3"
title %launcherName% ^| %launcherVersion%
set ram=1
set version=1.16.5
set name=Player
set forge=false
set "folder=launcher_data"
set "music=on"
set "per=off"
set "showVer=on"
set "start=call %folder%\bin\startfade.bat"
set "end=call %folder%\bin\endfade.bat"
set "localPath=%~dp0"
set "pythonPath=%localPath%\%folder%\bin\python"
set "python=%pythonPath%\python.exe"
if not exist "%folder%" mkdir "%folder%"
if not exist "%folder%\bin" mkdir "%folder%\bin"
if not exist "%folder%\data" mkdir "%folder%\data"
if not exist "%folder%\data\save.bat" (set firstTime=true) else (set firstTime=false)
Ping www.google.nl -n 1 -w 100000 >nul
if %errorlevel%==1 (set internet=false) else (set internet=true)
if %internet%==false call:checkOffline
if %firstTime%==true call:intro
call "%folder%\data\save.bat"
call:downloadFiles
if not exist "%python%" call:pythonInstall
wmic path win32_VideoController get name >"%folder%\data\gpu.txt"
more +1 "%folder%\data\gpu.txt" > "%folder%\data\gpu.data"
del "%folder%\data\gpu.txt"
if %music%==on "%folder%\bin\sound.exe" Play "%folder%\bin\music.wav" -1


:menu
%start%
echo %launcherName%
echo.
echo 1) Launch Minecraft %version%
echo 2) Launcher Settings
echo 3) List Minecraft versions
echo 4) Reinstall missing files
echo 5) Check for updates
echo 6) Exit
%end%
choice /c 123456 /n
if %errorlevel%==1 call:launch
if %errorlevel%==2 call:settings
if %errorlevel%==3 call:allVersions
if %errorlevel%==4 call:installJavaPython
if %errorlevel%==5 call:checkUpdates
if %errorlevel%==6 exit
goto menu

:settings
%start%
echo Launcher settings:
echo.
echo 1) Player name: %name%
echo 2) Game version: %version%
echo 3) Ram usage: %ram%
echo 4) Performance boost on launch: %per%
echo 5) List Minecraft Versions on the changing menu: %showVer%
echo 6) Menu
%end%
choice /c 123456 /n
if %errorlevel%==1 call:user
if %errorlevel%==2 call:version
if %errorlevel%==3 call:ram
if %errorlevel%==4 call:per
if %errorlevel%==5 call:showChange
if %errorlevel%==6 goto menu
goto settings

:showChange
%start%
echo Changing and saving settings...
%end%
if %showVer%==on (set showVer=off) else (set showVer=on)
call:save
timeout 0 /nobreak >nul
goto:EOF

:installJavaPython
%start%
echo Installing Java/Python...
%end%
call:fullInstallation
timeout 0 /nobreak >nul
goto menu

:checkUpdates
%start%
echo Checking for updates...
%end%
Ping www.google.nl -n 1 -w 100000 >nul
if errorlevel 1 (set internet=0) else (set internet=1)
if %internet%==0 call:checkInternet
if %internet%==0 goto:EOF
curl.exe -l -s -o "%folder%\data\latest.bat" "https://raw.githubusercontent.com/Kotsasmin/Minecraft_Launcher/main/latest.bat"
call %folder%\data\latest.bat
timeout 0 /nobreak >nul
if %latest%==%launcherVersion% goto noVersionAsk
:newVersionAsk
%start%
echo There is a new version...
echo Do you want to update now?
echo.
echo 1) Yes
echo 2) No
%end%
choice /c 12 /n
if %errorlevel%==1 goto update
if %errorlevel%==2 goto:EOF
goto newVersionAsk

:noVersionAsk
%start%
echo You are using the latest version of the Launcher.
echo Try again later...
%end%
pause>nul
goto menu

:update
%start%
echo Updating...
echo Please wait...
%end%
curl.exe -l -s -o "Minecraft Launcher %latest%.bat" "https://raw.githubusercontent.com/Kotsasmin/Minecraft_Launcher/main/launcher.bat"
start "" "Minecraft Launcher %latest%.bat"
exit

:music
%start%
echo Changing and saving settings...
%end%
if %music%==on (set music=off & "%folder%\bin\sound.exe" Stop "%folder%\bin\music.wav") else (set music=on & "%folder%\bin\sound.exe" Play "%folder%\bin\music.wav" -1)
call:save
timeout 0 /nobreak >nul
goto:EOF

:per
%start%
echo Changing and saving settings...
%end%
if %per%==on (set per=off) else (set per=on)
call:save
timeout 0 /nobreak >nul
goto:EOF

:user
%start%
echo Player name:
%end%
set /p "name="
call:save
goto:EOF

:version
if %showVer%==on call:allVersions
%start%
echo Minecraft version:
%end%
set /p "version="
call:save
goto:EOF

:ram
%start%
echo Ram usage in GB (without GB):
%end%
set /p "ram="
call:save
goto:EOF

:allVersions
(
echo @echo off
echo color f
echo title All Minecraft versions
echo echo Getting a list of all Minecraft versions...
echo "%python%" "%folder%\bin\bin.py" --main-dir "%folder%\bin" --work-dir "%folder%\data"  search
echo echo.
echo echo Make sure your buffer window size is larger than 700...
echo pause
echo exit
)>"%folder%\bin\versions.bat"
start "" "%folder%\bin\versions.bat"
goto:EOF

:launch
%start%
echo Initialization run...
%end%
set forge=false
if %forge%==true set forgeStart=forge:
"%folder%\bin\sound.exe" Stop "%folder%\bin\music.wav"
if %per%==on taskkill /f /im explorer.exe
"%python%" "%folder%\bin\bin.py" --main-dir "%folder%\bin" --work-dir "%folder%\data" start --jvm-args "-Xmx%ram%G -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M" %forgeStart%%version% -u "%name%" -i 0
if %music%==on "%folder%\bin\sound.exe" Play "%folder%\bin\music.wav" -1
if %per%==on start explorer.exe
goto menu

:internetError
%start%
echo Please check your internet connection
echo and try again later...
echo.
echo.
echo.
%end%
pause
exit

:fullInstallation
call:downloadFiles
call:pythonInstall
"%python%" "%folder%\bin\bin.py" start --dry %version%
goto :EOF

:save
(
echo set ram=%ram%
echo set version=%version%
echo set name=%name%
echo set forge=%forge%
echo set music=%music%
echo set per=%per%
echo set showVer=%showVer%
)>"%folder%\data\save.bat"
goto:EOF

:intro
call:fadeDownload
%start%
echo Since this is your first time using this Launcher,
echo the process of installing might take a while...
echo Approximately: 4-5 minutes
echo.
echo Please be patient...
%end%
call:downloadFiles
call:pythonInstall
call:user
call:version
call:save
%start%
echo Loading...
%end%
goto:EOF

:exit
%start%
%end%
exit

:downloadFiles
if not exist "%folder%\bin\bin.py" curl.exe -l -s -o "%folder%\bin\bin.py" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/bin.py"
if not exist "%folder%\bin\startfade.bat" curl.exe -l -s -o "%folder%\bin\startfade.bat" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/startfade.bat"
if not exist "%folder%\bin\endfade.bat" curl.exe -l -s -o "%folder%\bin\endfade.bat" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/endfade.bat"
if not exist "%folder%\bin\sound.exe" curl.exe -l -s -o "%folder%\bin\sound.exe" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/SOUND.EXE"
if not exist "%folder%\bin\music.wav" curl.exe -l -s -o "%folder%\bin\music.wav" "https://dl.dropboxusercontent.com/s/10kibegmkeb245e/menu3.wav?dl=0"
goto:EOF

:fadeDownload
if not exist "%folder%\bin\startfade.bat" curl.exe -l -s -o "%folder%\bin\startfade.bat" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/startfade.bat"
if not exist "%folder%\bin\endfade.bat" curl.exe -l -s -o "%folder%\bin\endfade.bat" "https://raw.githubusercontent.com/Kotsasmin/Kotsasmin_Download_Files/main/endfade.bat"
goto:EOF

:pythonInstall
if not exist "%pythonPath%" mkdir "%pythonPath%"
if not exist "%pythonPath%\setup.exe" curl.exe -s -l -o "%pythonPath%\setup.exe" https://www.python.org/ftp/python/3.10.1/python-3.10.1-amd64.exe
if exist "%python%" goto:EOF
"%pythonPath%\setup.exe" /i InstallAllUsers="1" TargetDir="%pythonPath%" PrependPath="1" Include_doc="1" Include_debug="1" Include_dev="1" Include_exe="1" Include_launcher="1" InstallLauncherAllUsers="1" Include_lib="1" Include_pip="1" Include_symbols="1" Include_tcltk="1" Include_test="1" Include_tools="1" Include_launcher="1" Include_launcher="1" Include_launcher="1" Include_launcher="1" Include_launcher="1" Include_launcher="1" /passive /wait
if exist "%USERPROFILE%\Desktop\launcher_data\bin\python\Lib\venv" del "%USERPROFILE%\Desktop\launcher_data\bin\python\Lib\venv"
timeout 0 /nobreak >nul
if exist "%python%" goto:EOF
if not exist "%userprofile%\Desktop" (set "errorMessage=noDesktop") else (set errorMessage=noPython)
if %errorMessage%==noDesktop goto noDesktop

:noPython
%start%
echo Something went wrong during the installation
echo of python... Try the followings:
echo.
echo 1) Restart your computer
echo 2) Change the location of the Launcher
echo 3) Check your Internet connection
%end%
pause>nul
exit

:noDesktop
%start%
echo Something went wrong during the installation
echo of python... Try the followings:
echo.
echo 1) Change the location of the Launcher
echo 2) Disable OneDrive
echo 3) Check your Internet connection
%end%
pause>nul
exit

:checkOffline
Ping www.google.nl -n 1 -w 100000 >nul
if %errorlevel%==1 (set internet=false) else (set internet=true)
if %internet%==true goto:EOF
if %firstTime%==true goto couldNotDownload
set readyOffline=true
if not exist "%folder%\bin\bin.py" set readyOffline=false
if not exist "%folder%\bin\startfade.bat" set readyOffline=false
if not exist "%folder%\bin\endfade.bat" set readyOffline=false
if not exist "%folder%\bin\sound.exe" set readyOffline=false
if not exist "%folder%\bin\music.wav" set readyOffline=false
if not exist "%python%" set readyOffline=false
if %readyOffline%==true goto offlineMode

:couldNotDownload
cls
echo Could not download some very important
echo files due to no Internet connection...
echo.
echo Please check your Internet connection and
echo try again later...
echo.
pause
exit

:offlineMode
cls
echo There is no Internet connection...
echo However, you can still play the installed
echo versions of Minecraft in Singleplayer mode...
echo.
pause
goto:eof

:checkInternet
%start%
echo Please check your internet connection and
echo try again later...
%end%
pause>nul
goto:EOF


:: Made by Kotsasmin
