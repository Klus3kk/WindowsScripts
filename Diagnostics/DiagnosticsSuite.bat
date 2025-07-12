@echo off
setlocal enabledelayedexpansion
title Windows System Diagnostics - Professional Edition
color 03

net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: Run as Administrator
    pause
    exit
)

cls
echo.
echo =============================================================================
echo                           WINDOWS SYSTEM DIAGNOSTICS
echo =============================================================================
echo.

echo [SYSTEM INFORMATION]
echo -----------------------------------------------------------------------------
systeminfo | findstr /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory" /C:"System Model" /C:"System Manufacturer" /C:"BIOS Version" /C:"System Boot Time"
echo.
echo Computer Serial Number:
wmic bios get SerialNumber /format:list | find "="
echo.
echo System UUID:
wmic csproduct get UUID /format:list | find "="
echo.

echo [HARDWARE DETAILS]
echo -----------------------------------------------------------------------------
echo CPU Information:
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,ProcessorId,Manufacturer /format:table
echo.
echo CPU Serial Numbers:
wmic cpu get ProcessorId,SerialNumber /format:list | find "="
echo.
echo Memory Modules:
wmic memorychip get Capacity,Speed,Manufacturer,PartNumber,SerialNumber,DeviceLocator,BankLabel /format:table
echo.
echo Memory Serial Numbers:
wmic memorychip get DeviceLocator,SerialNumber,PartNumber /format:list | find "="
echo.
echo Motherboard:
wmic baseboard get Product,Manufacturer,SerialNumber,Version /format:table
echo.
echo Graphics Cards:
wmic path win32_videocontroller get Name,DriverVersion,DriverDate,AdapterRAM,Status /format:table
echo.
echo Graphics Card Details:
wmic path win32_videocontroller get Name,PNPDeviceID /format:list | find "="
echo.
echo Sound Devices:
wmic sounddev get Name,Manufacturer,Status /format:table
echo.

echo [STORAGE INFORMATION]
echo -----------------------------------------------------------------------------
echo Physical Disks:
wmic diskdrive get Model,Size,InterfaceType,SerialNumber,Status,MediaType /format:table
echo.
echo Disk Serial Numbers:
wmic diskdrive get Model,SerialNumber /format:list | find "="
echo.
echo Disk Health (SMART Status):
wmic diskdrive get Status,Model /format:list | find "="
echo.
echo Logical Disks:
wmic logicaldisk get Size,FreeSpace,Caption,FileSystem,VolumeSerialNumber /format:table
echo.
echo Disk Usage:
for /f "tokens=1,2,3" %%a in ('wmic logicaldisk get size^,freespace^,caption /format:csv ^| find ":"') do (
    set /a total=%%c/1073741824 2>nul
    set /a free=%%b/1073741824 2>nul  
    set /a used=!total!-!free! 2>nul
    if !total! GTR 0 (
        set /a percent=!used!*100/!total! 2>nul
        echo Drive %%a: !used!GB/!total!GB used (!percent!%%)
    )
)
echo.

echo [NETWORK CONFIGURATION]
echo -----------------------------------------------------------------------------
echo Network Adapters:
wmic path win32_networkadapter where NetConnectionStatus=2 get Name,MACAddress,Speed,AdapterType /format:table
echo.
echo Network Adapter Details:
wmic path win32_networkadapter where NetConnectionStatus=2 get Name,MACAddress,PNPDeviceID /format:list | find "="
echo.
echo IP Configuration:
ipconfig /all | findstr /C:"Ethernet adapter" /C:"Wireless" /C:"IPv4" /C:"Subnet Mask" /C:"Default Gateway" /C:"DNS Servers" /C:"Physical Address"
echo.

echo [PERFORMANCE METRICS]
echo -----------------------------------------------------------------------------
echo Current CPU Usage:
wmic cpu get LoadPercentage /format:list | find "="
echo.
echo Memory Usage:
for /f "tokens=2 delims==" %%i in ('wmic OS get TotalVisibleMemorySize /value 2^>nul') do set totalMem=%%i
for /f "tokens=2 delims==" %%i in ('wmic OS get FreePhysicalMemory /value 2^>nul') do set freeMem=%%i
if defined totalMem if defined freeMem (
    set /a usedMem=%totalMem%-%freeMem% 2>nul
    set /a memPercent=%usedMem%*100/%totalMem% 2>nul
    echo Total Memory: %totalMem% KB
    echo Used Memory: %usedMem% KB (%memPercent%%%)
    echo Free Memory: %freeMem% KB
) else (
    echo Memory information unavailable
)
echo.
echo Process Count:
tasklist /fo csv | find /c """" 2>nul
echo.

echo [BATTERY INFORMATION]
echo -----------------------------------------------------------------------------
echo Battery Details:
wmic path win32_battery get Name,DeviceID,BatteryStatus,EstimatedChargeRemaining,EstimatedRunTime,FullChargeCapacity,DesignCapacity /format:table 2>nul || echo No battery detected
echo.
echo Battery Chemistry and Health:
wmic path win32_battery get Chemistry,DesignVoltage,ExpectedLife /format:list 2>nul | find "=" || echo No battery detected
echo.
echo Power Supply Info:
wmic path win32_battery get Availability,PowerManagementCapabilities /format:list 2>nul | find "=" || echo No battery detected
echo.
echo Battery Status Codes:
echo   1 = Other, 2 = Unknown, 3 = Fully Charged, 4 = Low, 5 = Critical
echo   6 = Charging, 7 = Charging and High, 8 = Charging and Low, 9 = Charging and Critical
echo   10 = Undefined, 11 = Partially Charged
echo.

echo [CRITICAL SERVICES STATUS]
echo -----------------------------------------------------------------------------
for %%s in ("Themes" "Spooler" "DHCP" "DNS" "Workstation" "Server" "EventLog" "PlugPlay" "RpcSs" "Winmgmt" "Windows Update" "Windows Defender" "Windows Time") do (
    sc query %%s 2>nul | findstr "STATE" | findstr "RUNNING" >nul && echo %%s: RUNNING || echo %%s: STOPPED
)
echo.

echo [SECURITY STATUS]
echo -----------------------------------------------------------------------------
echo Windows Defender Status:
powershell -ExecutionPolicy Bypass -Command "try { Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled,AntivirusEnabled,OnAccessProtectionEnabled,IoavProtectionEnabled,BehaviorMonitorEnabled,AntivirusSignatureLastUpdated | Format-List } catch { Write-Host 'Windows Defender info unavailable' }" 2>nul
echo.
echo Firewall Profiles:
netsh advfirewall show allprofiles state
echo.
echo User Account Information:
whoami /all | findstr /C:"User Name" /C:"SID" /C:"Privilege Name"
echo.
echo BitLocker Status:
manage-bde -status 2>nul || echo BitLocker status unavailable
echo.

@REM echo [RECENT SYSTEM ERRORS]
@REM echo -----------------------------------------------------------------------------
@REM echo System Log Errors (Last 10):
@REM wevtutil qe System /c:10 /rd:true /f:text /q:"*[System[(Level=1 or Level=2 or Level=3)]]" 2>nul | findstr /C:"Level" /C:"Date" /C:"Source" || echo No recent system errors
@REM echo.
@REM echo Application Log Errors (Last 10):
@REM wevtutil qe Application /c:10 /rd:true /f:text /q:"*[System[(Level=1 or Level=2 or Level=3)]]" 2>nul | findstr /C:"Level" /C:"Date" /C:"Source" || echo No recent application errors
@REM echo.

echo [HARDWARE SERIAL NUMBERS SUMMARY]
echo -----------------------------------------------------------------------------
echo System Serial Numbers:
echo BIOS/System:
wmic bios get SerialNumber /format:list | find "="
echo Motherboard:
wmic baseboard get SerialNumber /format:list | find "="
echo CPU:
wmic cpu get ProcessorId /format:list | find "="
echo Memory Modules:
wmic memorychip get DeviceLocator,SerialNumber /format:list | find "SerialNumber=" | find /v "SerialNumber="
echo Hard Drives:
wmic diskdrive get Model,SerialNumber /format:list | find "SerialNumber=" | find /v "SerialNumber="
echo.

echo [DRIVER STATUS]
echo -----------------------------------------------------------------------------
echo Checking for driver issues...
driverquery /v 2>nul | findstr /i "unknown\|error\|warning" || echo No driver issues found
echo.
echo USB Devices:
wmic path win32_usbcontrollerdevice get Dependent /format:list 2>nul | find "=" | find "USB" || echo No USB devices found
echo.

echo [STARTUP PROGRAMS]
echo -----------------------------------------------------------------------------
wmic startup get Caption,Command,Location,User /format:table
echo.

echo [ENVIRONMENT VARIABLES]
echo -----------------------------------------------------------------------------
echo PATH=%PATH%
echo TEMP=%TEMP%
echo WINDIR=%WINDIR%
echo PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITECTURE%
echo PROCESSOR_IDENTIFIER=%PROCESSOR_IDENTIFIER%
echo.

echo [POWER AND THERMAL]
echo -----------------------------------------------------------------------------
echo Power Scheme:
powercfg /getactivescheme
echo.
echo Power Configuration Details:
powercfg /query SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 2>nul | findstr "Current AC\|Current DC" || echo Power details unavailable
echo.
echo Thermal Information: 
:: in kelvins
wmic /namespace:\\root\wmi path MSAcpi_ThermalZoneTemperature get CurrentTemperature,InstanceName /format:list 2>nul | find "=" || echo Thermal sensors not available
echo.
echo Cooling Devices:
wmic path win32_fan get Name,Status /format:table 2>nul || echo No fan information available
echo.

echo [NETWORK DIAGNOSTICS]
echo -----------------------------------------------------------------------------
echo Testing Network Connectivity:
ping -n 2 127.0.0.1 | findstr "Reply\|Lost"
ping -n 2 8.8.8.8 | findstr "Reply\|Lost"
ping -n 2 1.1.1.1 | findstr "Reply\|Lost"
echo.
echo DNS Resolution Test:
nslookup google.com 2>nul | findstr "Address" || echo DNS resolution failed
echo.
echo Network Statistics:
netstat -e | findstr /C:"Bytes" /C:"Packets"
echo.
echo Active Network Connections:
netstat -an | findstr "ESTABLISHED" | find /c "ESTABLISHED" 2>nul && echo Active connections found || echo No active connections
echo.

echo [REGISTRY STATUS]
echo -----------------------------------------------------------------------------
echo Checking registry size...
dir "%WINDIR%\System32\config" | findstr /C:"SYSTEM" /C:"SOFTWARE" /C:"SAM" /C:"SECURITY"
echo.

echo [CONNECTED DEVICES]
echo -----------------------------------------------------------------------------
echo PCI Devices:
wmic path win32_pnpentity where "DeviceID like 'PCI%%'" get Name,DeviceID /format:table 2>nul || echo PCI device info unavailable
echo.
echo USB Devices:
wmic path win32_pnpentity where "DeviceID like 'USB%%'" get Name,DeviceID /format:table 2>nul || echo USB device info unavailable
echo.

echo [SYSTEM PERFORMANCE COUNTERS]
echo -----------------------------------------------------------------------------
echo Available Performance Counters:
typeperf -qx 2>nul | findstr /C:"Processor" /C:"Memory" /C:"PhysicalDisk" | find /c "\" && echo Performance counters available || echo Performance counters unavailable
echo.

echo [SYSTEM SUMMARY]
echo -----------------------------------------------------------------------------
echo Computer Name: %COMPUTERNAME%
echo Current User: %USERNAME%
echo Domain: %USERDOMAIN%
echo Logon Server: %LOGONSERVER%
echo Architecture: %PROCESSOR_ARCHITECTURE%
echo Number of Processors: %NUMBER_OF_PROCESSORS%
echo System Root: %SYSTEMROOT%
echo Current Directory: %CD%
echo System Uptime: 
systeminfo | findstr "System Boot Time"
echo Current Time: %DATE% %TIME%
echo.

:: Keep window open
pause
cmd /k