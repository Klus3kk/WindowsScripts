@echo off
echo Running network diagnostics...

echo Pinging Google...
ping google.com

echo Tracing route to Google...
tracert google.com

echo Checking DNS...

nslookup google.com

echo Diagnostics complete!
pause