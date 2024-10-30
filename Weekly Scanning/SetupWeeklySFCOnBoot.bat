@echo off
echo Creating a scheduled task for SFC scan...

schtasks /create /tn "WeeklySFCOnBoot" /tr "cmd.exe /c sfc /scannow" /sc weekly /d MON /st 09:00 /ru SYSTEM /ri 10 /du 6:00 /mo 1 /it

echo Scheduled task created successfully. SFC will run every Monday.
pause
