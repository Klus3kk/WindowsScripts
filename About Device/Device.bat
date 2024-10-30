@echo off
@REM Disk space info
wmic logicaldisk get name, size, freespace
@REM IP Fetcher
ipconfig | findstr /C:"IPv4"
nslookup myip.opendns.com resolver1.opendns.com | findstr /C:"Address"
@REM RAM Usage
systeminfo | findstr /C:"Total Physical Memory" /C:"Available Physical Memory"
@REM CPU/Memory Info
wmic cpu get name, maxclockspeed
wmic memorychip get capacity, speed

pause
