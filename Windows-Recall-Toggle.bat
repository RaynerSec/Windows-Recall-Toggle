@ECHO OFF
SETLOCAL EnableDelayedExpansion
CLS

:: BatchGotAdmin
:: Source: https://stackoverflow.com/a/10052222
:-------------------------------------
:: Check For Permissions
REM  --> Check For Permissions
IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

:: Not Admin
:: If Error Flag Set, We Do Not Have Admin.
REM --> If Error Flag Set, We Do Not Have Admin.
IF "%ERRORLEVEL%" NEQ "0" (
    :: Now Escalating Privileges
    ECHO Requesting Administrative Privileges...
    GOTO UACPrompt
) ELSE ( GOTO GotAdmin )

:: UAC Prompt
:UACPrompt
    ECHO Set UAC = CreateObject^("Shell.Application"^) >> "%TEMP%\getadmin.vbs"
    SET params= %*
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"
    "%TEMP%\getadmin.vbs"
    DEL "%TEMP%\getadmin.vbs"
    EXIT /B

:: Actual Script
:GotAdmin
    PUSHD "%CD%"
    CD /D "%~dp0"
:-------------------------------------

:: Menu
:MENU
SET VERSION=v1.0.0.0
TITLE Windows-Recall-Toggle %VERSION%
CLS
for /f "tokens=4-6 delims=[] " %%G in ('ver') do set WINVER=%%G
for /f "tokens=*" %%G in ('dism /online /get-featureinfo /featurename:recall ^| find /I "state"') do set WINDOWSRECALLSTATUS=%%G
ECHO ........................................................................................................................
:::   __          ___           _                          _____                _ _     _______                _      
:::   \ \        / (_)         | |                        |  __ \              | | |   |__   __|              | |
:::    \ \  /\  / / _ _ __   __| | _____      _____ ______| |__) |___  ___ __ _| | |______| | ___   __ _  __ _| | ___ 
:::     \ \/  \/ / | | '_ \ / _` |/ _ \ \ /\ / / __|______|  _  // _ \/ __/ _` | | |______| |/ _ \ / _` |/ _` | |/ _ \
:::      \  /\  /  | | | | | (_| | (_) \ V  V /\__ \      | | \ \  __/ (_| (_| | | |      | | (_) | (_| | (_| | |  __/
:::       \/  \/   |_|_| |_|\__,_|\___/ \_/\_/ |___/      |_|  \_\___|\___\__,_|_|_|      |_|\___/ \__, |\__, |_|\___|
:::                                                                                                 __/ | __/ |
:::                                                                                                |___/ |___/
:::
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
ECHO ........................................................................................................................
ECHO.
ECHO Windows-Recall-Toggle %VERSION%
ECHO.
ECHO Windows Version: %WINVER%
ECHO.
ECHO Windows Recall Status:
ECHO -----------------------------
IF /I "%WINDOWSRECALLSTATUS%" == "State : Enabled" (
    ECHO State : Enabled
) ELSE IF /I "%WINDOWSRECALLSTATUS%" == "State : Disabled" (
    ECHO State : Disabled
) ELSE (
    ECHO Unknown Windows Recall Status
)
ECHO -----------------------------
ECHO.
ECHO   1 - Enable Windows Recall
ECHO   2 - Disable Windows Recall
ECHO   3 - Info
ECHO   4 - Exit
ECHO.

:: Options Set By User
SET /P M="Select An Option And Then Press ENTER: "
IF "%M%" == "1" GOTO ENABLE
IF "%M%" == "2" GOTO DISABLE
IF "%M%" == "3" GOTO INFO
IF "%M%" == "4" GOTO EOF
GOTO MENU

:: Enable Windows Recall
:ENABLE
CLS
ECHO Enabling Windows Recall...
ECHO.
TIMEOUT 3 > NUL 2>&1
dism /online /enable-feature /featurename:recall
ECHO.
for /f "tokens=*" %%G in ('dism /online /get-featureinfo /featurename:recall ^| find /I "state"') do set WINDOWSRECALLSTATUS=%%G
ECHO Windows Recall Status:
ECHO -----------------------------
IF /I "%WINDOWSRECALLSTATUS%" == "State : Enabled" (
    ECHO State : Enabled
) ELSE IF /I "%WINDOWSRECALLSTATUS%" == "State : Disabled" (
    ECHO State : Disabled
) ELSE (
    ECHO Unknown Windows Recall Status
)
ECHO -----------------------------
ECHO.
GOTO REBOOT

:: Disable Windows Recall
:DISABLE
CLS
ECHO Disabling Windows Recall...
ECHO.
TIMEOUT 3 > NUL 2>&1
dism /online /disable-feature /featurename:recall
ECHO.
for /f "tokens=*" %%G in ('dism /online /get-featureinfo /featurename:recall ^| find /I "state"') do set WINDOWSRECALLSTATUS=%%G
ECHO Windows Recall Status:
ECHO -----------------------------
IF /I "%WINDOWSRECALLSTATUS%" == "State : Enabled" (
    ECHO State : Enabled
) ELSE IF /I "%WINDOWSRECALLSTATUS%" == "State : Disabled" (
    ECHO State : Disabled
) ELSE (
    ECHO Unknown Windows Recall Status
)
ECHO -----------------------------
ECHO.
GOTO REBOOT

:: Show Info
:INFO
CLS
ECHO ==========================================================
ECHO.
ECHO  Windows-Recall-Toggle %VERSION%
ECHO.
ECHO  Made By RC Chuah-(RaynerSec)
ECHO.
ECHO  https://github.com/rc-chuah/Windows-Recall-Toggle
ECHO  https://github.com/RaynerSec/Windows-Recall-Toggle
ECHO ----------------------------------------------------------
ECHO                  -- Licensed GNU GPL v3.0 --
ECHO.
ECHO  A Batch Script Made For Easily Disabling And Enabling
ECHO  Windows Recall For Privacy And Security Reasons Without
ECHO  Uninstalling Windows Recall Features In Windows.
ECHO  Feel Free To Contribute On The Github Page.
ECHO.
ECHO   1 - Main Menu
ECHO   2 - Exit
ECHO.
ECHO ==========================================================
ECHO.

:: Options Set By User
SET /P N="Select An Option And Then Press ENTER: "
IF "%N%" == "1" GOTO MENU
IF "%N%" == "2" GOTO EOF

:: Reboot
:REBOOT
ECHO Operation Complete, Reboot Is Required To Apply Changes.
ECHO.
    :: Options Set By User
    SET /P O="Do You Want To Reboot Now? [Y/n]: "
    IF /I "%O%" == "y" (
        CLS
        ECHO Reboot Initiated, Rebooting In 10 Seconds.
        TIMEOUT 3 > NUL 2>&1
        shutdown /r /t 10 /soft /c "Windows-Recall-Toggle Reboot Procedure"
        ECHO  Rebooting In Progress...
        ECHO.
        ECHO  Press Enter To Exit Windows-Recall-Toggle.
        ECHO.
        PAUSE
        EXIT /B %ERRORLEVEL%
    )
    ELSE (
        CLS
        ECHO You Chose Not To Reboot Now, Reboot Later To Apply Changes.
        TIMEOUT 3 > NUL 2>&1
        ECHO  Going Back To The Main Menu...
        ECHO.
        ECHO  Press Enter To Go Back To The Main Menu.
        ECHO.
        PAUSE
        GOTO MENU
)

:: End Of File
:EOF
EXIT /B %ERRORLEVEL%