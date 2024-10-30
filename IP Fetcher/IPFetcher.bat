@echo off
echo Fetching IP information...
ipconfig | findstr /C:"IPv4"
nslookup myip.opendns.com resolver1.opendns.com | findstr /C:"Address"
echo IP information fetched!
pause
