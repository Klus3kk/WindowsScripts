@echo off
set /p time=Enter time in minutes: 
@REM Enter the time here
shutdown -s -t %time% * 60 
pause
