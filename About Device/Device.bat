@echo off
echo ==============================
echo    About Device Information
echo ==============================
echo Timestamp: %date% %time%
echo.

@REM Disk Space Info
echo --- Disk Space Info ---
wmic logicaldisk get name, size, freespace
echo.

@REM IP Fetcher
echo --- IP Information ---
ipconfig | findstr /C:"IPv4"
nslookup myip.opendns.com resolver1.opendns.com | findstr /C:"Address"
echo.

@REM RAM Usage
echo --- RAM Usage ---
systeminfo | findstr /C:"Total Physical Memory" /C:"Available Physical Memory"
echo.

@REM CPU and Memory Info
echo --- CPU and Memory Info ---
wmic cpu get name, maxclockspeed
wmic memorychip get capacity, speed
echo.

@REM OS Info
echo --- Operating System Info ---
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
echo.

@REM User Info
echo --- User and Computer Info ---
echo User: %username%
echo Computer: %computername%
echo.

@REM Battery Status
echo --- Battery Status ---
powercfg /batteryreport
echo Battery report saved. Opening...
start battery-report.html
echo.

@REM Wait for user to close
echo ==============================
echo         End of Report
echo ==============================
pause
