@echo off
setlocal enabledelayedexpansion
color 0A
title Windows Device Diagnostics - Comprehensive System Analysis

:: Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

:: Create output directory
set "OUTPUT_DIR=%~dp0DiagnosticsReport_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "OUTPUT_DIR=%OUTPUT_DIR: =0%"
mkdir "%OUTPUT_DIR%" 2>nul

echo ==========================================
echo    WINDOWS DEVICE DIAGNOSTICS SUITE
echo ==========================================
echo.
echo Creating comprehensive system report...
echo Output directory: %OUTPUT_DIR%
echo.

:: 1. SYSTEM INFORMATION
echo [1/15] Collecting System Information...
echo ========================================== > "%OUTPUT_DIR%\01_SystemInfo.txt"
echo SYSTEM INFORMATION >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo ========================================== >> "%OUTPUT_DIR%\01_SystemInfo.txt"
systeminfo >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo. >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo COMPUTER SYSTEM DETAILS >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo ======================== >> "%OUTPUT_DIR%\01_SystemInfo.txt"
wmic computersystem get model,manufacturer,systemtype,totalphysicalmemory /format:list >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo. >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo BIOS INFORMATION >> "%OUTPUT_DIR%\01_SystemInfo.txt"
echo ================= >> "%OUTPUT_DIR%\01_SystemInfo.txt"
wmic bios get serialnumber,version,releasedate,manufacturer /format:list >> "%OUTPUT_DIR%\01_SystemInfo.txt"

:: 2. HARDWARE INFORMATION
echo [2/15] Collecting Hardware Information...
echo ========================================== > "%OUTPUT_DIR%\02_Hardware.txt"
echo HARDWARE INFORMATION >> "%OUTPUT_DIR%\02_Hardware.txt"
echo ========================================== >> "%OUTPUT_DIR%\02_Hardware.txt"
echo. >> "%OUTPUT_DIR%\02_Hardware.txt"
echo CPU INFORMATION >> "%OUTPUT_DIR%\02_Hardware.txt"
echo =============== >> "%OUTPUT_DIR%\02_Hardware.txt"
wmic cpu get name,manufacturer,maxclockspeed,numberofcores,numberoflogicalprocessors,architecture /format:list >> "%OUTPUT_DIR%\02_Hardware.txt"
echo. >> "%OUTPUT_DIR%\02_Hardware.txt"
echo MEMORY INFORMATION >> "%OUTPUT_DIR%\02_Hardware.txt"
echo ================== >> "%OUTPUT_DIR%\02_Hardware.txt"
wmic memorychip get capacity,speed,manufacturer,partnumber,serialnumber,devicelocator /format:list >> "%OUTPUT_DIR%\02_Hardware.txt"
echo. >> "%OUTPUT_DIR%\02_Hardware.txt"
echo MOTHERBOARD INFORMATION >> "%OUTPUT_DIR%\02_Hardware.txt"
echo ======================== >> "%OUTPUT_DIR%\02_Hardware.txt"
wmic baseboard get product,manufacturer,serialnumber,version /format:list >> "%OUTPUT_DIR%\02_Hardware.txt"
echo. >> "%OUTPUT_DIR%\02_Hardware.txt"
echo GRAPHICS CARD INFORMATION >> "%OUTPUT_DIR%\02_Hardware.txt"
echo ========================= >> "%OUTPUT_DIR%\02_Hardware.txt"
wmic path win32_videocontroller get name,driverversion,driverdate,adapterram,status /format:list >> "%OUTPUT_DIR%\02_Hardware.txt"

:: 3. DISK INFORMATION
echo [3/15] Collecting Disk Information...
echo ========================================== > "%OUTPUT_DIR%\03_Disks.txt"
echo DISK INFORMATION >> "%OUTPUT_DIR%\03_Disks.txt"
echo ========================================== >> "%OUTPUT_DIR%\03_Disks.txt"
echo. >> "%OUTPUT_DIR%\03_Disks.txt"
echo PHYSICAL DISKS >> "%OUTPUT_DIR%\03_Disks.txt"
echo ============== >> "%OUTPUT_DIR%\03_Disks.txt"
wmic diskdrive get size,model,interfacetype,serialnumber,status,mediatype /format:list >> "%OUTPUT_DIR%\03_Disks.txt"
echo. >> "%OUTPUT_DIR%\03_Disks.txt"
echo LOGICAL DISKS >> "%OUTPUT_DIR%\03_Disks.txt"
echo ============= >> "%OUTPUT_DIR%\03_Disks.txt"
wmic logicaldisk get size,freespace,filesystem,volumename,description /format:list >> "%OUTPUT_DIR%\03_Disks.txt"
echo. >> "%OUTPUT_DIR%\03_Disks.txt"
echo DISK USAGE >> "%OUTPUT_DIR%\03_Disks.txt"
echo ========== >> "%OUTPUT_DIR%\03_Disks.txt"
for /f "tokens=1,2,3" %%a in ('wmic logicaldisk get size^,freespace^,caption') do (
    if "%%a" neq "" if "%%a" neq "Caption" (
        echo Drive %%a - Free: %%b bytes, Total: %%c bytes >> "%OUTPUT_DIR%\03_Disks.txt"
    )
)

:: 4. NETWORK INFORMATION
echo [4/15] Collecting Network Information...
echo ========================================== > "%OUTPUT_DIR%\04_Network.txt"
echo NETWORK INFORMATION >> "%OUTPUT_DIR%\04_Network.txt"
echo ========================================== >> "%OUTPUT_DIR%\04_Network.txt"
echo. >> "%OUTPUT_DIR%\04_Network.txt"
echo NETWORK ADAPTERS >> "%OUTPUT_DIR%\04_Network.txt"
echo ================ >> "%OUTPUT_DIR%\04_Network.txt"
wmic path win32_networkadapter get name,adaptertype,macaddress,speed,netconnectionstatus /format:list >> "%OUTPUT_DIR%\04_Network.txt"
echo. >> "%OUTPUT_DIR%\04_Network.txt"
echo NETWORK CONFIGURATION >> "%OUTPUT_DIR%\04_Network.txt"
echo ====================== >> "%OUTPUT_DIR%\04_Network.txt"
ipconfig /all >> "%OUTPUT_DIR%\04_Network.txt"
echo. >> "%OUTPUT_DIR%\04_Network.txt"
echo ROUTING TABLE >> "%OUTPUT_DIR%\04_Network.txt"
echo ============= >> "%OUTPUT_DIR%\04_Network.txt"
route print >> "%OUTPUT_DIR%\04_Network.txt"
echo. >> "%OUTPUT_DIR%\04_Network.txt"
echo ARP TABLE >> "%OUTPUT_DIR%\04_Network.txt"
echo ========= >> "%OUTPUT_DIR%\04_Network.txt"
arp -a >> "%OUTPUT_DIR%\04_Network.txt"
echo. >> "%OUTPUT_DIR%\04_Network.txt"
echo NETWORK STATISTICS >> "%OUTPUT_DIR%\04_Network.txt"
echo ================== >> "%OUTPUT_DIR%\04_Network.txt"
netstat -e >> "%OUTPUT_DIR%\04_Network.txt"

:: 5. INSTALLED SOFTWARE
echo [5/15] Collecting Installed Software...
echo ========================================== > "%OUTPUT_DIR%\05_Software.txt"
echo INSTALLED SOFTWARE >> "%OUTPUT_DIR%\05_Software.txt"
echo ========================================== >> "%OUTPUT_DIR%\05_Software.txt"
echo. >> "%OUTPUT_DIR%\05_Software.txt"
echo INSTALLED PROGRAMS >> "%OUTPUT_DIR%\05_Software.txt"
echo ================== >> "%OUTPUT_DIR%\05_Software.txt"
wmic product get name,version,vendor,installdate /format:list >> "%OUTPUT_DIR%\05_Software.txt"
echo. >> "%OUTPUT_DIR%\05_Software.txt"
echo WINDOWS FEATURES >> "%OUTPUT_DIR%\05_Software.txt"
echo ================ >> "%OUTPUT_DIR%\05_Software.txt"
dism /online /get-features /format:table >> "%OUTPUT_DIR%\05_Software.txt"

:: 6. SERVICES
echo [6/15] Collecting Services Information...
echo ========================================== > "%OUTPUT_DIR%\06_Services.txt"
echo SERVICES INFORMATION >> "%OUTPUT_DIR%\06_Services.txt"
echo ========================================== >> "%OUTPUT_DIR%\06_Services.txt"
echo. >> "%OUTPUT_DIR%\06_Services.txt"
echo RUNNING SERVICES >> "%OUTPUT_DIR%\06_Services.txt"
echo ================ >> "%OUTPUT_DIR%\06_Services.txt"
sc query state= all >> "%OUTPUT_DIR%\06_Services.txt"
echo. >> "%OUTPUT_DIR%\06_Services.txt"
echo SERVICE DETAILS >> "%OUTPUT_DIR%\06_Services.txt"
echo =============== >> "%OUTPUT_DIR%\06_Services.txt"
wmic service get name,displayname,state,startmode,pathname /format:list >> "%OUTPUT_DIR%\06_Services.txt"

:: 7. STARTUP PROGRAMS
echo [7/15] Collecting Startup Programs...
echo ========================================== > "%OUTPUT_DIR%\07_Startup.txt"
echo STARTUP PROGRAMS >> "%OUTPUT_DIR%\07_Startup.txt"
echo ========================================== >> "%OUTPUT_DIR%\07_Startup.txt"
echo. >> "%OUTPUT_DIR%\07_Startup.txt"
echo STARTUP ITEMS >> "%OUTPUT_DIR%\07_Startup.txt"
echo ============= >> "%OUTPUT_DIR%\07_Startup.txt"
wmic startup get caption,command,location,user /format:list >> "%OUTPUT_DIR%\07_Startup.txt"
echo. >> "%OUTPUT_DIR%\07_Startup.txt"
echo SCHEDULED TASKS >> "%OUTPUT_DIR%\07_Startup.txt"
echo =============== >> "%OUTPUT_DIR%\07_Startup.txt"
schtasks /query /fo LIST /v >> "%OUTPUT_DIR%\07_Startup.txt"

:: 8. RUNNING PROCESSES
echo [8/15] Collecting Running Processes...
echo ========================================== > "%OUTPUT_DIR%\08_Processes.txt"
echo RUNNING PROCESSES >> "%OUTPUT_DIR%\08_Processes.txt"
echo ========================================== >> "%OUTPUT_DIR%\08_Processes.txt"
echo. >> "%OUTPUT_DIR%\08_Processes.txt"
echo PROCESS LIST >> "%OUTPUT_DIR%\08_Processes.txt"
echo ============ >> "%OUTPUT_DIR%\08_Processes.txt"
tasklist /fo table /v >> "%OUTPUT_DIR%\08_Processes.txt"
echo. >> "%OUTPUT_DIR%\08_Processes.txt"
echo PROCESS DETAILS >> "%OUTPUT_DIR%\08_Processes.txt"
echo =============== >> "%OUTPUT_DIR%\08_Processes.txt"
wmic process get name,processid,parentprocessid,executablepath,commandline,workingsetsize /format:list >> "%OUTPUT_DIR%\08_Processes.txt"

:: 9. PERFORMANCE COUNTERS
echo [9/15] Collecting Performance Data...
echo ========================================== > "%OUTPUT_DIR%\09_Performance.txt"
echo PERFORMANCE COUNTERS >> "%OUTPUT_DIR%\09_Performance.txt"
echo ========================================== >> "%OUTPUT_DIR%\09_Performance.txt"
echo. >> "%OUTPUT_DIR%\09_Performance.txt"
echo PERFORMANCE MONITORING >> "%OUTPUT_DIR%\09_Performance.txt"
echo ====================== >> "%OUTPUT_DIR%\09_Performance.txt"
wmic cpu get loadpercentage /format:list >> "%OUTPUT_DIR%\09_Performance.txt"
echo. >> "%OUTPUT_DIR%\09_Performance.txt"
echo MEMORY USAGE >> "%OUTPUT_DIR%\09_Performance.txt"
echo ============ >> "%OUTPUT_DIR%\09_Performance.txt"
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory,TotalVirtualMemorySize,FreeVirtualMemory /format:list >> "%OUTPUT_DIR%\09_Performance.txt"
echo. >> "%OUTPUT_DIR%\09_Performance.txt"
echo DISK PERFORMANCE >> "%OUTPUT_DIR%\09_Performance.txt"
echo ================ >> "%OUTPUT_DIR%\09_Performance.txt"
wmic logicaldisk get size,freespace,caption /format:list >> "%OUTPUT_DIR%\09_Performance.txt"

:: 10. EVENT LOGS
echo [10/15] Collecting Event Logs...
echo ========================================== > "%OUTPUT_DIR%\10_EventLogs.txt"
echo EVENT LOGS >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo ========================================== >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo. >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo SYSTEM ERRORS (Last 50) >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo ======================== >> "%OUTPUT_DIR%\10_EventLogs.txt"
wevtutil qe System /c:50 /rd:true /f:text /q:"*[System[(Level=1 or Level=2 or Level=3)]]" >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo. >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo APPLICATION ERRORS (Last 50) >> "%OUTPUT_DIR%\10_EventLogs.txt"
echo ============================= >> "%OUTPUT_DIR%\10_EventLogs.txt"
wevtutil qe Application /c:50 /rd:true /f:text /q:"*[System[(Level=1 or Level=2 or Level=3)]]" >> "%OUTPUT_DIR%\10_EventLogs.txt"

:: 11. SYSTEM HEALTH
echo [11/15] Running System Health Checks...
echo ========================================== > "%OUTPUT_DIR%\11_SystemHealth.txt"
echo SYSTEM HEALTH CHECKS >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo ========================================== >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo. >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo SYSTEM FILE CHECKER >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo =================== >> "%OUTPUT_DIR%\11_SystemHealth.txt"
sfc /scannow >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo. >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo DISK CHECK >> "%OUTPUT_DIR%\11_SystemHealth.txt"
echo ========== >> "%OUTPUT_DIR%\11_SystemHealth.txt"
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo Checking drive %%d: >> "%OUTPUT_DIR%\11_SystemHealth.txt"
        chkdsk %%d: /f /v >> "%OUTPUT_DIR%\11_SystemHealth.txt" 2>&1
        echo. >> "%OUTPUT_DIR%\11_SystemHealth.txt"
    )
)

:: 12. DRIVERS
echo [12/15] Collecting Driver Information...
echo ========================================== > "%OUTPUT_DIR%\12_Drivers.txt"
echo DRIVER INFORMATION >> "%OUTPUT_DIR%\12_Drivers.txt"
echo ========================================== >> "%OUTPUT_DIR%\12_Drivers.txt"
echo. >> "%OUTPUT_DIR%\12_Drivers.txt"
echo INSTALLED DRIVERS >> "%OUTPUT_DIR%\12_Drivers.txt"
echo ================= >> "%OUTPUT_DIR%\12_Drivers.txt"
driverquery /fo table /v >> "%OUTPUT_DIR%\12_Drivers.txt"
echo. >> "%OUTPUT_DIR%\12_Drivers.txt"
echo DRIVER DETAILS >> "%OUTPUT_DIR%\12_Drivers.txt"
echo ============== >> "%OUTPUT_DIR%\12_Drivers.txt"
wmic systemdriver get name,pathname,state,status,startmode /format:list >> "%OUTPUT_DIR%\12_Drivers.txt"

:: 13. SECURITY INFORMATION
echo [13/15] Collecting Security Information...
echo ========================================== > "%OUTPUT_DIR%\13_Security.txt"
echo SECURITY INFORMATION >> "%OUTPUT_DIR%\13_Security.txt"
echo ========================================== >> "%OUTPUT_DIR%\13_Security.txt"
echo. >> "%OUTPUT_DIR%\13_Security.txt"
echo FIREWALL STATUS >> "%OUTPUT_DIR%\13_Security.txt"
echo =============== >> "%OUTPUT_DIR%\13_Security.txt"
netsh advfirewall show allprofiles >> "%OUTPUT_DIR%\13_Security.txt"
echo. >> "%OUTPUT_DIR%\13_Security.txt"
echo WINDOWS DEFENDER STATUS >> "%OUTPUT_DIR%\13_Security.txt"
echo ======================= >> "%OUTPUT_DIR%\13_Security.txt"
powershell -command "Get-MpComputerStatus" >> "%OUTPUT_DIR%\13_Security.txt"
echo. >> "%OUTPUT_DIR%\13_Security.txt"
echo USER ACCOUNTS >> "%OUTPUT_DIR%\13_Security.txt"
echo ============= >> "%OUTPUT_DIR%\13_Security.txt"
wmic useraccount get name,sid,disabled,lockout,passwordexpires /format:list >> "%OUTPUT_DIR%\13_Security.txt"
echo. >> "%OUTPUT_DIR%\13_Security.txt"
echo LOCAL GROUPS >> "%OUTPUT_DIR%\13_Security.txt"
echo ============= >> "%OUTPUT_DIR%\13_Security.txt"
wmic group get name,sid,description /format:list >> "%OUTPUT_DIR%\13_Security.txt"

:: 14. TEMPERATURE AND SENSORS
echo [14/15] Collecting Temperature Data...
echo ========================================== > "%OUTPUT_DIR%\14_Temperature.txt"
echo TEMPERATURE AND SENSORS >> "%OUTPUT_DIR%\14_Temperature.txt"
echo ========================================== >> "%OUTPUT_DIR%\14_Temperature.txt"
echo. >> "%OUTPUT_DIR%\14_Temperature.txt"
echo THERMAL INFORMATION >> "%OUTPUT_DIR%\14_Temperature.txt"
echo =================== >> "%OUTPUT_DIR%\14_Temperature.txt"
wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature,InstanceName /format:list >> "%OUTPUT_DIR%\14_Temperature.txt"
echo. >> "%OUTPUT_DIR%\14_Temperature.txt"
echo POWER SETTINGS >> "%OUTPUT_DIR%\14_Temperature.txt"
echo =============== >> "%OUTPUT_DIR%\14_Temperature.txt"
powercfg /query >> "%OUTPUT_DIR%\14_Temperature.txt"
echo. >> "%OUTPUT_DIR%\14_Temperature.txt"
echo BATTERY INFORMATION >> "%OUTPUT_DIR%\14_Temperature.txt"
echo =================== >> "%OUTPUT_DIR%\14_Temperature.txt"
wmic path win32_battery get name,estimatedchargeremaining,estimatedruntime,batterystatus /format:list >> "%OUTPUT_DIR%\14_Temperature.txt"

:: 15. CONNECTIVITY TESTS
echo [15/15] Running Connectivity Tests...
echo ========================================== > "%OUTPUT_DIR%\15_Connectivity.txt"
echo CONNECTIVITY TESTS >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo ========================================== >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo. >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo PING TESTS >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo ========== >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo Testing Google DNS... >> "%OUTPUT_DIR%\15_Connectivity.txt"
ping -n 4 8.8.8.8 >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo. >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo Testing Cloudflare DNS... >> "%OUTPUT_DIR%\15_Connectivity.txt"
ping -n 4 1.1.1.1 >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo. >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo Testing Microsoft... >> "%OUTPUT_DIR%\15_Connectivity.txt"
ping -n 4 microsoft.com >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo. >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo DNS RESOLUTION >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo ============== >> "%OUTPUT_DIR%\15_Connectivity.txt"
nslookup google.com >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo. >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo OPEN PORTS >> "%OUTPUT_DIR%\15_Connectivity.txt"
echo ========== >> "%OUTPUT_DIR%\15_Connectivity.txt"
netstat -an >> "%OUTPUT_DIR%\15_Connectivity.txt"

:: Create Summary Report
echo Creating Summary Report...
echo ========================================== > "%OUTPUT_DIR%\00_SUMMARY.txt"
echo WINDOWS DEVICE DIAGNOSTICS SUMMARY >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo ========================================== >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo. >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo Report Generated: %date% %time% >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo Computer: %COMPUTERNAME% >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo User: %USERNAME% >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo. >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo REPORT CONTENTS: >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo ================ >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 01 - System Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 02 - Hardware Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 03 - Disk Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 04 - Network Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 05 - Installed Software >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 06 - Services Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 07 - Startup Programs >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 08 - Running Processes >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 09 - Performance Data >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 10 - Event Logs >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 11 - System Health Checks >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 12 - Driver Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 13 - Security Information >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 14 - Temperature and Sensors >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo 15 - Connectivity Tests >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo. >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo QUICK SYSTEM OVERVIEW: >> "%OUTPUT_DIR%\00_SUMMARY.txt"
echo ====================== >> "%OUTPUT_DIR%\00_SUMMARY.txt"
systeminfo | findstr /i "OS Name OS Version System Model System Type Total Physical Memory" >> "%OUTPUT_DIR%\00_SUMMARY.txt"

echo.
echo ==========================================
echo DIAGNOSTICS COMPLETE!
echo ==========================================
echo.
echo Report saved to: %OUTPUT_DIR%
echo.
echo Summary of files created:
echo - 00_SUMMARY.txt        (Overview and index)
echo - 01_SystemInfo.txt     (System information)
echo - 02_Hardware.txt       (Hardware details)
echo - 03_Disks.txt          (Disk information)
echo - 04_Network.txt        (Network configuration)
echo - 05_Software.txt       (Installed software)
echo - 06_Services.txt       (Windows services)
echo - 07_Startup.txt        (Startup programs)
echo - 08_Processes.txt      (Running processes)
echo - 09_Performance.txt    (Performance data)
echo - 10_EventLogs.txt      (System event logs)
echo - 11_SystemHealth.txt   (Health checks)
echo - 12_Drivers.txt        (Driver information)
echo - 13_Security.txt       (Security settings)
echo - 14_Temperature.txt    (Temperature/power)
echo - 15_Connectivity.txt   (Network tests)
echo.
echo Press any key to open the report folder...
pause >nul
explorer "%OUTPUT_DIR%"