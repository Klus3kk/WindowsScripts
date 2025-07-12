@echo off
setlocal enabledelayedexpansion
color 0E
title Advanced Windows System Diagnostics

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Administrator privileges required.
    pause
    exit /b 1
)

cls
echo.
echo ╔═══════════════════════════════════════════════════════════════════════════════╗
echo ║                        ADVANCED SYSTEM DIAGNOSTICS                           ║
echo ╚═══════════════════════════════════════════════════════════════════════════════╝
echo.

:: System Information
echo ┌─ SYSTEM OVERVIEW ─────────────────────────────────────────────────────────────┐
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "OS Name"') do set "osname=%%i"
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "OS Version"') do set "osver=%%i"
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "System Model"') do set "model=%%i"
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "System Type"') do set "arch=%%i"
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "Total Physical Memory"') do set "ram=%%i"
for /f "tokens=2 delims=:" %%i in ('systeminfo ^| findstr /i "System Boot Time"') do set "boottime=%%i"

echo   OS:%osname%
echo   Version:%osver%
echo   Model:%model%
echo   Architecture:%arch%
echo   RAM:%ram%
echo   Last Boot:%boottime%
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: CPU Details
echo ┌─ CPU ANALYSIS ────────────────────────────────────────────────────────────────┐
for /f "tokens=2 delims==" %%i in ('wmic cpu get name /value ^| find "="') do set "cpuname=%%i"
for /f "tokens=2 delims==" %%i in ('wmic cpu get maxclockspeed /value ^| find "="') do set "cpuspeed=%%i"
for /f "tokens=2 delims==" %%i in ('wmic cpu get numberofcores /value ^| find "="') do set "cores=%%i"
for /f "tokens=2 delims==" %%i in ('wmic cpu get numberoflogicalprocessors /value ^| find "="') do set "threads=%%i"
for /f "tokens=2 delims==" %%i in ('wmic cpu get loadpercentage /value ^| find "="') do set "cpuload=%%i"

echo   Processor: %cpuname%
echo   Base Clock: %cpuspeed% MHz
echo   Cores: %cores% ^| Threads: %threads%
echo   Current Load: %cpuload%%%
echo.

:: Check CPU features
echo   Features:
wmic cpu get virtualizationFirmwareEnabled,vmmonitormodeextensions,secondleveladdresstranslationextensions /format:list | findstr /v "^$"
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Memory Analysis
echo ┌─ MEMORY ANALYSIS ─────────────────────────────────────────────────────────────┐
for /f "tokens=2 delims==" %%i in ('wmic OS get TotalVisibleMemorySize /value ^| find "="') do set /a "totalmem=%%i/1024"
for /f "tokens=2 delims==" %%i in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set /a "freemem=%%i/1024"
set /a "usedmem=%totalmem%-%freemem%"
set /a "mempercent=(%usedmem%*100)/%totalmem%"

echo   Total RAM: %totalmem% MB
echo   Used: %usedmem% MB (%mempercent%%%)
echo   Free: %freemem% MB
echo.
echo   Memory Modules:
wmic memorychip get capacity,speed,manufacturer,partnumber,devicelocator /format:table | findstr /v "^$"
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Storage Analysis
echo ┌─ STORAGE ANALYSIS ────────────────────────────────────────────────────────────┐
echo   Physical Drives:
for /f "skip=1 tokens=1,2,3,4" %%a in ('wmic diskdrive get model^,size^,interfacetype^,status') do (
    if "%%a" neq "" (
        set /a "size=%%b/1073741824" 2>nul
        if !size! gtr 0 echo     %%a - !size! GB ^(%%c^) - %%d
    )
)
echo.
echo   Logical Drives:
for /f "tokens=1,2,3,4" %%a in ('wmic logicaldisk get caption^,size^,freespace^,filesystem') do (
    if "%%a" neq "" if "%%a" neq "Caption" (
        set /a "total=%%b/1073741824" 2>nul
        set /a "free=%%c/1073741824" 2>nul
        set /a "used=!total!-!free!" 2>nul
        if !total! gtr 0 (
            set /a "percent=(!used!*100)/!total!" 2>nul
            echo     %%a !used!/!total! GB ^(!percent!%% used^) - %%d
        )
    )
)
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Network Analysis
echo ┌─ NETWORK ANALYSIS ────────────────────────────────────────────────────────────┐
echo   Active Network Adapters:
for /f "skip=1 tokens=1,2,3" %%a in ('wmic path win32_networkadapter where "NetConnectionStatus=2" get name^,macaddress^,speed') do (
    if "%%a" neq "" if "%%b" neq "" (
        echo     %%a
        echo       MAC: %%b
        if "%%c" neq "" (
            set /a "speed=%%c/1000000" 2>nul
            if !speed! gtr 0 echo       Speed: !speed! Mbps
        )
    )
)
echo.
echo   IP Configuration:
ipconfig | findstr /i "adapter ethernet wireless" -A 3
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Performance Monitoring
echo ┌─ PERFORMANCE METRICS ─────────────────────────────────────────────────────────┐
echo   Real-time Performance:
for /f "tokens=2 delims==" %%i in ('wmic cpu get loadpercentage /value ^| find "="') do set "cpu=%%i"
echo     CPU Usage: %cpu%%%

:: Get memory usage
for /f "tokens=4" %%i in ('tasklist /fi "imagename eq svchost.exe" ^| find "svchost.exe"') do set "mem=%%i"
echo     Memory: %mempercent%%% used

:: Get disk activity
echo     Disk Activity:
for /f "skip=1 tokens=1" %%a in ('wmic logicaldisk get caption') do (
    if "%%a" neq "" (
        for /f %%b in ('dir %%a\ ^| find "bytes free"') do echo       %%a Active
    )
)

:: Top processes by memory
echo.
echo   Top Memory Consumers:
tasklist /fo csv | sort /r /+5 | head -6 | findstr /v "Image Name"
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Security Status
echo ┌─ SECURITY STATUS ─────────────────────────────────────────────────────────────┐
echo   Windows Defender:
powershell -command "try { $status = Get-MpComputerStatus; Write-Host '    Real-time Protection:' $status.RealTimeProtectionEnabled; Write-Host '    Antivirus Enabled:' $status.AntivirusEnabled; Write-Host '    Last Quick Scan:' $status.QuickScanStartTime } catch { Write-Host '    Status: Unable to retrieve' }"

echo.
echo   Firewall Status:
netsh advfirewall show allprofiles state | findstr "State"

echo.
echo   User Account Control:
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA 2>nul | findstr "EnableLUA"
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: System Health
echo ┌─ SYSTEM HEALTH ───────────────────────────────────────────────────────────────┐
echo   Windows Updates:
powershell -command "try { $updates = Get-WmiObject -Class Win32_QuickFixEngineering | Sort-Object InstalledOn -Descending | Select-Object -First 3; foreach ($update in $updates) { Write-Host '    ' $update.HotFixID '-' $update.InstalledOn } } catch { Write-Host '    Unable to retrieve update info' }"

echo.
echo   System Uptime:
for /f "tokens=2 delims==" %%i in ('wmic OS get LastBootUpTime /value ^| find "="') do set "boottime=%%i"
powershell -command "$boot = [Management.ManagementDateTimeConverter]::ToDateTime('%boottime%'); $uptime = (Get-Date) - $boot; Write-Host '    ' $uptime.Days 'days,' $uptime.Hours 'hours,' $uptime.Minutes 'minutes'"

echo.
echo   Event Log Errors (Last 24h):
for /f %%i in ('wevtutil qe System /c:1000 /rd:true /f:text /q:"*[System[TimeCreated[timediff(@SystemTime) <= 86400000] and (Level=1 or Level=2)]]" ^| find /c "Level:"') do echo     System Errors: %%i
for /f %%i in ('wevtutil qe Application /c:1000 /rd:true /f:text /q:"*[System[TimeCreated[timediff(@SystemTime) <= 86400000] and (Level=1 or Level=2)]]" ^| find /c "Level:"') do echo     Application Errors: %%i

echo.
echo   Running Services:
for /f %%i in ('sc query state^= all ^| find /c "RUNNING"') do echo     Active Services: %%i
for /f %%i in ('sc query state^= all ^| find /c "STOPPED"') do echo     Stopped Services: %%i
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Temperature and Power
echo ┌─ THERMAL & POWER ─────────────────────────────────────────────────────────────┐
echo   Power Profile:
powercfg /getactivescheme | find "GUID"

echo.
echo   Battery Status:
wmic path win32_battery get estimatedchargeremaining,estimatedruntime,batterystatus /format:list 2>nul | findstr /v "^$" || echo     No battery detected

echo.
echo   Thermal Zones:
wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature,InstanceName /format:list 2>nul | findstr /v "^$" || echo     No thermal sensors available
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Advanced Diagnostics
echo ┌─ ADVANCED DIAGNOSTICS ────────────────────────────────────────────────────────┐
echo   Hardware Compatibility:
driverquery /v | findstr /i "error problem" || echo     No driver issues detected

echo.
echo   System File Integrity:
sfc /verifyonly | findstr /i "found integrity violations" || echo     System files: OK

echo.
echo   Startup Performance:
powershell -command "try { $boot = Get-WinEvent -FilterHashtable @{LogName='System'; ID=12} -MaxEvents 1; $kernel = Get-WinEvent -FilterHashtable @{LogName='System'; ID=27} -MaxEvents 1; Write-Host '    Last boot took:' ([datetime]$kernel.TimeCreated - [datetime]$boot.TimeCreated).TotalSeconds 'seconds' } catch { Write-Host '    Boot time data unavailable' }"

echo.
echo   Network Connectivity:
ping -n 1 8.8.8.8 >nul && echo     Internet: Connected || echo     Internet: Disconnected
ping -n 1 127.0.0.1 >nul && echo     Localhost: OK || echo     Localhost: Failed

echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

:: Critical Issues Detection
echo ┌─ CRITICAL ISSUES DETECTION ───────────────────────────────────────────────────┐
set "issues=0"

:: Check disk space
for /f "tokens=3" %%i in ('dir c:\ ^| find "bytes free"') do (
    set "freespace=%%i"
    set "freespace=!freespace:,=!"
    if !freespace! lss 5368709120 (
        echo   [WARNING] Low disk space on C: drive
        set /a "issues+=1"
    )
)

:: Check memory usage
if %mempercent% gtr 90 (
    echo   [WARNING] High memory usage: %mempercent%%%
    set /a "issues+=1"
)

:: Check CPU usage
if %cpu% gtr 90 (
    echo   [WARNING] High CPU usage: %cpu%%%
    set /a "issues+=1"
)

if %issues% equ 0 echo   No critical issues detected
echo └───────────────────────────────────────────────────────────────────────────────┘
echo.

echo Diagnostics completed. Press any key to exit...
pause >nul