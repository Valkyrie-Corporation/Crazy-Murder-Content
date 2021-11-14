:: gmod-content-installer.bat
:: Games Feeder GMOD Content Installer
:: @author Kogium <kogium@valkyrie.zone>
:: @date 13/11/2021
:: version 1.1
::----------------------------------------------

:: hide extra stuff
@ECHO OFF

:: clear the screen
cls

:: Context menu privilege.
call :check_Permissions

setlocal ENABLEEXTENSIONS
setlocal ENABLEDELAYEDEXPANSION

:: Path to Sublime Text installation dir.
SET bin64path="%programfiles(x86)%"
SET bin32path="%programfiles%"

:::    _____                             ______            _
:::   / ____|                           |  ____|          | |
:::  | |  __  __ _ _ __ ___   ___  ___  | |__ ___  ___  __| | ___ _ __
:::  | | |_ |/ _` | '_ ` _ \ / _ \/ __| |  __/ _ \/ _ \/ _` |/ _ \ '__|
:::  | |__| | (_| | | | | | |  __/\__ \ | | |  __/  __/ (_| |  __/ |
:::   \_____|\__,_|_| |_| |_|\___||___/ |_|  \___|\___|\__,_|\___|_|
:::
:::            => [ GMOD CONTENT INSTALLER FOR WINDOWS ] <=
:::
:::
:::  Games Feeder (c) 2013-2021. All Rights Reserved.
:::
:::
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
echo ===================================
echo # SEARCHING STEAM PATH . . .

set KEY_NAME="HKCU\SOFTWARE\Valve\Steam"
set KEY_VALUE=SteamPath
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY %KEY_NAME% /v %KEY_VALUE%`) DO (
  set STEAMPATH=%%A %%B
)
if defined STEAMPATH (
  echo STEAM PATH found.
) else (
  set KEY_NAME="HKLM\SOFTWARE\Valve\Steam"
  set KEY_VALUE=InstallPath
  FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY %KEY_NAME% /v %KEY_VALUE%`) DO (
    set STEAMPATH=%%A %%B
  )
  if defined STEAMPATH (
    echo STEAM PATH found.
  ) else (
    set KEY_NAME="HKLM\SOFTWARE\WOW6432Node\Valve\Steam"
    set KEY_VALUE=InstallPath
    FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY %KEY_NAME% /v %KEY_VALUE%`) DO (
      set STEAMPATH=%%A %%B
    )
    if defined STEAMPATH (
      echo STEAM PATH found.
    ) else (
      echo ===================================
      echo Steam path could not be found on your computer.
      echo ===================================
      pause
      goto :EOF
    )
  )
)

IF exist "%STEAMPATH%" (
  echo STEAM PATH exist.
) else (
  echo ===================================
  echo Steam path could not be found on your computer.
  echo ===================================
  pause
  goto :EOF
)

SET GMODSTEAMPATH="%STEAMPATH%\steamapps\common\GarrysMod\garrysmod"
SET VDFCONFIG="%STEAMPATH%\config\libraryfolders.vdf"
SET VDFSTEAMAPPS="%STEAMPATH%\steamapps\libraryfolders.vdf"

echo # SEARCHING GMOD CONTENT PATH . . .
IF exist %GMODSTEAMPATH% (
  echo GMOD PATH exist.
  goto :continuestep
) else (
  goto :checkvdfconfig
)

:checkvdfconfig
IF exist %VDFCONFIG% (
  for /F "usebackq tokens=2*" %%A in (`findstr /I "path" %VDFCONFIG%`) do (
    set "gmodpath=%%~A %%~B"
    :: Tricks for remove the last double quote
    set "gmodpath=!gmodpath:~0,-1!"
    SET "gmodpath=!gmodpath:\\=\!"
    set "gmodpath=!gmodpath!\steamapps\common\GarrysMod\garrysmod"
    IF exist !gmodpath! (
      set STEAMGMODVDFPATH="!gmodpath!"
      goto :continuevdfconfig
    )
  )
  :continuevdfconfig
  if defined STEAMGMODVDFPATH (
    echo GMOD CUSTOM PATH exist.
    SET GMODSTEAMPATH=%STEAMGMODVDFPATH%
    goto :continuestep
  ) else (
    goto :checkvdfsteamapps
  )
) else (
  goto :checkvdfsteamapps
)

:checkvdfsteamapps
IF exist %VDFSTEAMAPPS% (
  for /F "usebackq tokens=2*" %%A in (`findstr /I "path" %VDFSTEAMAPPS%`) do (
    set "gmodpath=%%~A %%~B"
    :: Tricks for remove the last double quote
    set "gmodpath=!gmodpath:~0,-1!"
    SET "gmodpath=!gmodpath:\\=\!"
    set "gmodpath=!gmodpath!\steamapps\common\GarrysMod\garrysmod"
    IF exist !gmodpath! (
      set STEAMGMODVDFPATH="!gmodpath!"
      goto :continuevdfsteamapps
    )
  )
  :continuevdfsteamapps
  if defined STEAMGMODVDFPATH (
    echo GMOD CUSTOM PATH exist.
    SET GMODSTEAMPATH=%STEAMGMODVDFPATH%
    goto :continuestep
  ) else (
    echo ===================================
    echo Garrys Mod could not be found on your computer.
    echo ===================================
    pause
    goto :EOF
  )
) else (
  echo ===================================
  echo STEAM LIBRARY FOLDER could not be found on your computer.
  echo ===================================
  pause
  goto :EOF
)

:continuestep
echo %GMODSTEAMPATH%
echo ===================================
echo script done! press any key to leave.
echo ===================================
pause
goto :EOF

:check_Permissions
net session >nul 2>&1
if %errorLevel% == 0 (
  goto :EOF
) else (
  echo ===================================
  echo # Administrative permissions required.
  echo Failure: Current permissions inadequate. Try to get elevation...
  echo ===================================
  CHOICE /C YNC /M "Press Y to restart the script as local administrator, N for Cancel."
  IF %ERRORLEVEL% EQU 1 goto CONTINUE
  IF %ERRORLEVEL% EQU 2 goto END
  IF %ERRORLEVEL% EQU 3 goto END

  :END
  exit

  :CONTINUE
  SET openwithsublime_elevation=1
  call %elevate.CmdPath% %~fs0
  exit
)
goto :EOF