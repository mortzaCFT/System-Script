@echo off
color 04
title %random%%random% 

::check The File systems
::And other ....
::----------------------------------------
::Got Admin(in win10 only...)


>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
echo:
echo   Requesting Administrative Privileges...
echo   Press YES in UAC Prompt to Continue
echo:

    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
	
	
::----------------------------------------
::Main
:main
mode con cols=128 lines=30
echo                                      ----------Creator"mortza"-----------
echo                                      -----This Script Can Help Yur pc----
echo                                                ###############
echo                                          Select By name Wihch You need
echo                                              ( and Press ENTER :)
ECHO.
echo          +--------------------------------------------------------------------------------------------------+
echo           +        ^|                                                                         ^|        +     
echo            +      ^|        ^| 1)System Check                                                ^|          +
echo           +        ^|                                                                         ^|        +
echo            +      ^|        ^| 2)System_File_Repair                                          ^|          +
echo.          +       ^|                                                                          ^|        +
echo            +       ^|       ^| 3)Reboot-to-Windows-Recovery-mode                             ^|          +
echo.          +       ^|                                                                          ^|        +
echo            +       ^|       ^| 4)Auto-Update-En_Dis-Win10                                    ^|          +
echo.          +       ^|                                                                          ^|        +
echo            +       ^|       ^| 5)Auto-Update-Enable_Disable-Win10                            ^|          +
echo.          +       ^|                                                                          ^|          +
echo           +--------------------------------------------------------------------------------------------------+
echo.                                                                                                 

set /p c=Select option:
if /I "%c%" EQU "1" goto :SyTch
if /I "%c%" EQU "2" goto :SyFr
if /I "%c%" EQU "3" goto :RToRecovery
if /I "%c%" EQU "4" goto :AutoUPT
if /I "%C%" EQU "5" goto :DeUPt
echo "%c%" is not valid pls select 1 to 5 option!
goto :main
pause >NUL


::----------------------------------------


:SyTch
cls
echo.  ---     ----       ---
echo  +Win10 System File Check+
echo.  ---     ----        ---
 
CHOICE /c YN /n /M "Run this script? (Y/N): "
SET ERRORTEMP=%ERRORLEVEL%
IF %ERRORTEMP% EQU 0 EXIT
IF %ERRORTEMP% EQU 2 EXIT
SFC /SCANNOW
:FINISHED
Echo.
ECHO -------------------------------------------------------------------------------
Echo. Process has completed. If it shows corruption you should run repair script
ECHO -------------------------------------------------------------------------------
echo Press any key to exit...
pause>NUL
goto :EOF


::----------------------------------------


:SyFr
cls
SetLocal EnableDelayedExpansion

echo.
echo       ---     ----       ---
echo.   +Windows System File Restore+
echo       ---     ----       ---
echo.
echo       =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo    ^|        #+#+#+#+#+#+#+#+#+            ^| 
echo    ^| This Script can repair your files... ^|
echo    ^| this script using the online source  ^|
echo    ^|   (in online mode rarely works...)   ^|
echo    ^|        #+#+#+#+#+#+#+#+#+            ^|
echo       =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.

CHOICE /c YN /n /M "Run this script? (Y/N): "
IF %ERRORLEVEL% NEQ 1 EXIT
SET INSTALLIMAGE=""
SET SPLIT=0
SET ESDFILE=0

FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.wim" SET INSTALLIMAGE="%%i:\Sources\install.wim"&GOTO :finding)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.esd" SET INSTALLIMAGE="%%i:\Sources\install.esd"&SET ESDFILE=1&GOTO :finding)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.swm" SET INSTALLIMAGE="%%i:\Sources\install.swm"&SET SPLIT=1&SET SPLITPATTERN="%%i:\Sources\install*.swm"&GOTO :finding)

::online Source Download....
IF NOT EXIST !INSTALLIMAGE! (
CLS
echo 0000000000000000000000000000000000000000000000000000000000000000000000000000000
echo.               No install image found: Attempting online restore
echo ###############################################################################
dism /online /cleanup-image /restorehealth
GOTO :end
)

:finding
CLS
ECHO Scanning !INSTALLIMAGE! to create the index list file...
IF EXIST "%TEMP%\IMAGELIST.TXT" del /q/f "%TEMP%\IMAGELIST.TXT"
IF EXIST "%TEMP%\install.wim" del /q/f "%TEMP%\install.wim"
for /f "tokens=2 delims=: " %%a in ('dism /Get-WimInfo /WimFile:!INSTALLIMAGE! ^| find /i "Index"') do (
for /f "tokens=2 delims=:" %%g in ('dism /Get-WimInfo /WimFile:!INSTALLIMAGE! /Index:%%a ^| find /i "Name"') do (ECHO %%a.%%g>>%TEMP%\IMAGELIST.TXT))
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo ++++ INDEX  ++++

:display index
TYPE %TEMP%\IMAGELIST.TXT
ECHO --------> select index or Q to exit 
SET INPUT=
SET /P INPUT="Please select an Index Number or Q to exit: "
IF NOT DEFINED INPUT GOTO :IMAGESELECTION
IF /I '!INPUT!'=='Q' GOTO :end
SET INDEX=!INPUT!

:CONFIRMINDEX
echo.
Echo You have selected Index: %INDEX%
dism /get-wiminfo /wimfile:%INSTALLIMAGE% /index:%INDEX%>NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 GOTO :FOUNDIMG
choice /c yn /n /m "Are you sure you wish to use this index? (Y/N): "
IF !ERRORLEVEL! NEQ 1 GOTO :FOUNDIMG
IF %SPLIT%==1 GOTO :FOUNDSPLIT
IF %ESDFILE%==1 GOTO :FOUNDESD

:Using normal wim
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.Repairing System Files
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-

dism /online /cleanup-image /restorehealth:wim:"%INSTALLIMAGE%":1
goto :end


:FOUNDSPLIT
echo -------
echo.Script is exporting split-wim file to a normal wim
echo. This will take a while
echo -------
dism /export-image /sourceimagefile:%INSTALLIMAGE% /swmfile:%SPLITPATTERN% /sourceindex:%INDEX% /destinationimagefile:%TEMP%\install.wim /compress:max
IF %ERRORLEVEL% NEQ 0 (ECHO There was a problem exporting this index to temp folder&pause&GOTO :end)
echo  =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.   Repairing System Files
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
dism /online /cleanup-image /restorehealth:wim:"%TEMP%\install.wim":1
GOTO :end

:FOUNDESD
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo. Script is exporting esd file to a normal wim
echo. This will take a while
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
dism /export-image /sourceimagefile:%INSTALLIMAGE% /sourceindex:%INDEX% /destinationimagefile:%TEMP%\install.wim /compress:max
IF %ERRORLEVEL% NEQ 0 (ECHO There was a problem exporting this index to temp folder&pause&GOTO :end)
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.                         Repairing System Files
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
dism /online /cleanup-image /restorehealth:wim:"%TEMP%\install.wim":1
GOTO :end


:end
IF EXIST "%TEMP%\IMAGELIST.TXT" del /q/f "%TEMP%\IMAGELIST.TXT"
IF EXIST "%TEMP%\install.wim" del /q/f "%TEMP%\install.wim"
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.           Finished
ECHO =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Press any key to exit...
pause>NUL
goto :main


::----------------------------------------


:RToRecovery
cls
pushd "%CD%"
CD /D "%~dp0"
(NET FILE||(powershell -command Start-Process '%0' -Verb runAs -ArgumentList '%* '&EXIT /B))>NUL 2>NUL

echo ---------
echo.Windows Recovery Environment Scheduler
echo ---------
echo.
CHOICE /c YN /n /M "Run this script? (Y/N): "
set errortemp=%ERRORLEVEL%
IF %ERRORTEMP% EQU 2 EXIT
IF %ERRORTEMP% EQU 0 EXIT
%WINDIR%\system32\reagentc.exe /boottore
ECHO --------------
echo.    :)
echo --------------
CHOICE /c YN /n /M "Reboot your system now? (Y/N): "
set errortemp=%ERRORLEVEL%
IF %ERRORTEMP% EQU 2 EXIT
IF %ERRORTEMP% EQU 0 EXIT
shutdown /r /t 0


::----------------------------------------
:AutoUPT


::Check Version System,,,,
wmic os get version | find /i "10.">nul 2>nul
if %errorlevel% neq 0 GOTO :Not10
(reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate"|find /i "0x1")>NUL 2>NUL
if %errorlevel% neq 0 GOTO :KEYOFF

:KEYON
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Automatic Updates are currently disabled.
echo Would you like to re-enable them? (Y/N)
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.
choice /c yn /n
If %ERRORLEVEL% NEQ 1 GOTO :QUIT

echo Attempting to shut down the Windows Update service if it's running
net stop wuauserv>NUL 2>NUL
echo.

Echo Changing Registry key
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /D 0 /T REG_DWORD /F>NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ERROR
Echo.

Echo Automatic Updates have been enabled
Echo.
goto :QUIT


:KEYOFF
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Automatic Updates are currently enabled.
echo Would you like to disable them? (Y/N)
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.
choice /c yn /n
If %ERRORLEVEL% NEQ 1 GOTO :QUIT

echo Attempting to shut down the Windows Update service if it's running
net stop wuauserv>NUL 2>NUL
echo.

Echo Changing Registry key
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /D 1 /T REG_DWORD /F>NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ERROR
Echo.

Echo Automatic Updates have been disabled
Echo.
goto :QUIT


:QUIT
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main

:ERROR
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo The script ran into an unexpected error setting reg key.
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main

:Not10
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo This script is only designed for Windows 10...
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main


::----------------------------------------

:DeUPt
@echo off

title Disable/Enable Windows 10 Automatic Device Driver Updates
color 1f
:Begin UAC check and Auto-Elevate Permissions
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo:
echo   Requesting Administrative Privileges...
echo   Press YES in UAC Prompt to Continue
echo:

    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:Check Windows Version
wmic os get version | find /i "10.">nul 2>nul
if %errorlevel% neq 0 GOTO :Not10

:Check the key:
(reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig"|find /i "0x0")>NUL 2>NUL
if %errorlevel% neq 0 GOTO :KEYOFF

:KEYON
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Device Driver Automatic Updates are currently disabled.
echo Would you like to re-enable them? (Y/N)
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.
choice /c yn /n
If %ERRORLEVEL% NEQ 1 GOTO :QUIT

echo Attempting to shut down the Windows Update service if it's running
net stop wuauserv>NUL 2>NUL
echo.

Echo Changing Registry key
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /D 1 /T REG_DWORD /F>NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ERROR
Echo.

Echo Device Driver Automatic Updates have been enabled
Echo.
goto :QUIT


:KEYOFF
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Device Driver Automatic Updates are currently enabled.
echo Would you like to disable them? (Y/N)
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo.
choice /c yn /n
If %ERRORLEVEL% NEQ 1 GOTO :QUIT

echo Attempting to shut down the Windows Update service if it's running
net stop wuauserv>NUL 2>NUL
echo.

Echo Changing Registry key
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /D 0 /T REG_DWORD /F>NUL 2>NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ERROR
Echo.

Echo Driver Automatic Updates have been disabled
Echo.
goto :QUIT


:QUIT
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main

:ERROR
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo The script ran into an unexpected error setting reg key.
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main

:Not10
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
echo This script is only designed for Windows 10...
echo Press any key to exit...
echo =--=-=-=-=-=-=-=-=-=-=-=-=-=-=-==-=-
pause>NUL
goto :main
