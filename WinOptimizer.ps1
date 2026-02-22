<#
.SYNOPSIS
    WinOptimizer - Ultimate Windows 11 Optimization & Maintenance Tool.

.DESCRIPTION
    A comprehensive, all-in-one PowerShell script for Windows 10/11 optimization,
    diagnostics, and maintenance. Features 20 interactive tools:

    DIAGNOSTICS (1-5):
      1. Full System Health Report (10-section report saved to Desktop)
      2. Quick RAM & CPU Check (instant visual bars)
      3. Identify Heavy Processes (top 15 + browser RAM + kill option)
      4. Battery Health Report (powercfg + charge/cycle stats)
      5. Disk & Hardware Health (S.M.A.R.T., temperatures, reliability counters)

    OPTIMIZATION (6-12):
      6. Startup Optimizer (80+ known patterns, protected whitelist, task cleanup)
      7. RAM & Performance (EmptyWorkingSet API, visual effects, power plan)
      8. Deep Disk Clean (7-step: temp, 12 browsers, WU cache, CleanMgr, TRIM)
      9. Network Repair (VPN-safe, DNS flush, TCP tuning, DNS provider config)
     10. Service Optimization (SSD/HDD-aware, Defender tuning, telemetry disable)
     11. Privacy & Telemetry Shield (15+ registry settings across 8 categories)
     12. Windows Update Manager (pause/resume, active hours, cache clear)

    REPAIR & MAINTENANCE (13-16):
     13. Repair Windows (Full DISM+SFC, Quick SFC, Image Repair, Disk Check, Error Viewer)
     14. Create System Restore Point (verified creation with shadow copy check)
     15. Clean Old Restore Points (keep N newest, vssadmin deletion)
     16. Cleanup Script Logs & Reports (auto/interactive, age-based filtering)

    ALL-IN-ONE & EXTRAS (17-20):
     17. Run ALL Optimizations (8-step pipeline with error resilience)
     18. Software Update Manager (Winget: check, update, search, install, list)
     19. Bloatware Uninstaller (definite junk + popular tiers, 4 removal modes)
     20. Storage Space Analyzer (visual bars, folder scan, recommendations)

    Safety features:
      - Automatic restore point creation before system changes
      - Protected process whitelist (22 critical processes never trimmed)
      - Protected startup whitelist (drivers, security, system essentials)
      - VPN/VM adapter auto-detection (skips destructive network resets)
      - SSD/HDD auto-detection with 4 fallback methods
      - Domain-joined PC detection (preserves network policies)
      - Configurable thresholds via $Config block at top of script

.NOTES
    Version:        3.4
    Author:         Prakhar Aggarwal
    Requires:       Windows 10/11, PowerShell 5.1+, Administrator privileges
    Last Updated:   February 2026
    Repository:     https://github.com/Prakhar0206/WinOptimizer

.EXAMPLE
    # Method 1 - Double-click the batch launcher (recommended):
    Run-Optimizer.bat

    # Method 2 - Run from PowerShell (as Administrator):
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\WinOptimizer.ps1

.LINK
    https://github.com/Prakhar0206/WinOptimizer
#>

# ============================================
# WINOPTIMIZER - Ultimate Windows Optimization
# All-in-one script for Windows 10/11
# Author: Prakhar Aggarwal
# Version: 3.4
# ============================================

$scriptVersion = "3.4"
$scriptDate = "February 2026"

# Visual settings
$block = [char]0x2588  # Full Block (Nice graphic)
$shade = [char]0x2591  # Light Shade

# Set console size: 120 columns wide, 3000 lines buffer (scrollback history)
try {
    $psHost = Get-Host
    $psWindow = $psHost.UI.RawUI
    $newSize = $psWindow.WindowSize
    $newSize.Width = 120
    $newSize.Height = 40
    
    $newBuffer = $psWindow.BufferSize
    $newBuffer.Width = 120
    $newBuffer.Height = 3000

    $psWindow.BufferSize = $newBuffer
    $psWindow.WindowSize = $newSize
}
catch {
    # Fails in some terminals (ISE, VS Code, Windows Terminal sometimes), safe to ignore
}

$desktopPath = [Environment]::GetFolderPath('Desktop')
$logFile = "$desktopPath\Optimizer_Log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
$script:skipPause = $false

# ============================================
# CONFIGURATION — Edit these values to customize
# ============================================
$Config = @{
    # RAM Optimizer: only trim processes using more than this (in MB)
    RamTrimThresholdMB    = 50

    # Disk Cleanup: delete old logs/crash dumps older than this (in days)
    LogCleanupDays        = 30

    # Restore Points: how many to keep when cleaning old ones
    RestorePointsToKeep   = 2

    # Windows Update: max days a user can pause (1 to this value)
    MaxUpdatePauseDays    = 35

    # Defender: max CPU % during scans (lower = less impact, 5-50)
    DefenderMaxCpuPercent = 15

    # DNS Providers: primary and secondary for each option
    DnsProviders          = @{
        Google     = @("8.8.8.8", "8.8.4.4")
        Cloudflare = @("1.1.1.1", "1.0.0.1")
        Quad9      = @("9.9.9.9", "149.112.112.112")
    }

    # Processes that should NEVER have their working set trimmed
    ProtectedProcesses    = @(
        "csrss", "lsass", "smss", "wininit", "services", "svchost",
        "dwm", "explorer", "ShellExperienceHost", "StartMenuExperienceHost",
        "MsMpEng", "MsSense", "NisSrv", "SecurityHealthService",
        "audiodg", "fontdrvhost", "System", "Registry", "Memory Compression",
        "SearchIndexer", "RuntimeBroker", "WmiPrvSE"
    )

    # Network adapter patterns to detect VPN/VM (skip destructive resets)
    VpnAdapterPatterns    = @(
        "*VPN*", "*Virtual*", "*VMware*", "*VirtualBox*", "*Docker*",
        "*Hyper-V*", "*vEthernet*", "*Loopback*", "*WSL*", "*TAP*",
        "*TUN*", "*Cisco*", "*Fortinet*", "*GlobalProtect*",
        "*WireGuard*", "*OpenVPN*", "*Tunnel*"
    )
}

$script:LoggingEnabled = $false

# ============================================
# LOGGING SYSTEM
# ============================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    
    # Always show in console
    switch ($Level) {
        "SUCCESS" { Write-Host "  [OK] $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "  [!!] $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "  [XX] $Message" -ForegroundColor Red }
        "STEP" { Write-Host "  >>> $Message" -ForegroundColor Cyan }
        "HEADER" { Write-Host "`n  $Message" -ForegroundColor Cyan }
        default { Write-Host "    $Message" -ForegroundColor $Color }
    }
    
    # Only write to file if enabled (Option 20)
    if ($script:LoggingEnabled) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] $Message"
        $logEntry | Out-File -FilePath $logFile -Append -ErrorAction SilentlyContinue
    }
}

# ============================================
# INPUT VALIDATION HELPER
# ============================================
function Get-ValidYN {
    param([string]$Prompt)
    do {
        Write-Host "$Prompt (Y/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
        if ($response -notmatch '^[YyNn]$') {
            Write-Host "  Please enter Y or N." -ForegroundColor Red
        }
    } while ($response -notmatch '^[YyNn]$')
    return ($response -match '^[Yy]$')
}
# ============================================
# RESTORE POINT CREATION
# ============================================
function New-SafeRestorePoint {
    param(
        [string]$Description = "Pre-Optimizer v$scriptVersion Backup"
    )
    Write-Log "Creating System Restore Point..." "STEP"
    try {
        # Enable System Restore if disabled
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        
        # Check last restore point time (Windows limits to 1 per 24hrs by default)
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
        Set-ItemProperty -Path $regPath -Name "SystemRestorePointCreationFrequency" -Value 0 -ErrorAction SilentlyContinue
        
        # Capture existing count to verify after creation
        $beforeCount = (Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Measure-Object).Count
        
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        # Verify the restore point was actually created
        Start-Sleep -Seconds 2
        $afterCount = (Get-ComputerRestorePoint -ErrorAction SilentlyContinue | Measure-Object).Count
        if ($afterCount -gt $beforeCount) {
            $latestRP = Get-ComputerRestorePoint | Select-Object -Last 1
            Write-Log "Restore point created & verified (ID: $($latestRP.SequenceNumber))" "SUCCESS"
            return $true
        }
        else {
            Write-Log "Restore point command succeeded but could not verify creation" "WARNING"
            Write-Host "    Tip: Open Control Panel > System > System Protection to check manually" -ForegroundColor Gray
            return $true
        }
    }
    catch {
        Write-Log "Could not create restore point: $($_.Exception.Message)" "WARNING"
        Write-Host "    Possible causes:" -ForegroundColor Gray
        Write-Host "      - System Restore is disabled (Control Panel > System > System Protection)" -ForegroundColor Gray
        Write-Host "      - Insufficient disk space for shadow copies" -ForegroundColor Gray
        Write-Host "      - Volume Shadow Copy (VSS) service is not running" -ForegroundColor Gray
        Write-Host "    Fix: Run 'services.msc' and start 'Volume Shadow Copy' service" -ForegroundColor Gray
        return $false
    }
}

# ============================================
# ADMIN CHECK
# ============================================
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`nERROR: This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# ============================================
# MENU SYSTEM
# ============================================
function Show-Menu {
    Clear-Host
    
    # Live system stats for header
    $ramPct = 0; $cpuLoad = 0
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        if ($os) {
            $totalRAM = $os.TotalVisibleMemorySize / 1MB
            $usedRAM = ($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB
            $ramPct = [math]::Round(($usedRAM / $totalRAM) * 100)
        }
        $cpuLoad = (Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue).LoadPercentage
        if (-not $cpuLoad) { $cpuLoad = 0 }
    }
    catch {}
    
    $title = "ULTIMATE LAPTOP OPTIMIZER v$scriptVersion"
    $sub = "Windows 11  |  $scriptDate"
    
    Write-Host ""
    Write-Host "   +============================================+" -ForegroundColor Cyan
    Write-Host "   |  $($title.PadRight(42))|" -ForegroundColor Cyan
    Write-Host "   |  $($sub.PadRight(42))|" -ForegroundColor DarkCyan
    Write-Host "   +============================================+" -ForegroundColor Cyan
    
    # Live mini status bar
    $ramFill = [math]::Floor($ramPct / 10); $cpuFill = [math]::Floor($cpuLoad / 10)
    $ramBar = $block.ToString() * $ramFill + $shade.ToString() * (10 - $ramFill)
    $cpuBar = $block.ToString() * $cpuFill + $shade.ToString() * (10 - $cpuFill)
    $ramClr = if ($ramPct -lt 60) { "Green" } elseif ($ramPct -lt 80) { "Yellow" } else { "Red" }
    $cpuClr = if ($cpuLoad -lt 40) { "Green" } elseif ($cpuLoad -lt 75) { "Yellow" } else { "Red" }
    
    Write-Host -NoNewline "     RAM " -ForegroundColor Gray
    Write-Host -NoNewline "[$ramBar]" -ForegroundColor $ramClr
    Write-Host -NoNewline " $($ramPct.ToString().PadLeft(3))%" -ForegroundColor $ramClr
    Write-Host -NoNewline "    CPU " -ForegroundColor Gray
    Write-Host -NoNewline "[$cpuBar]" -ForegroundColor $cpuClr
    Write-Host " $($cpuLoad.ToString().PadLeft(3))%" -ForegroundColor $cpuClr
    Write-Host ""
    
    Write-Host "   --- DIAGNOSTICS & ANALYSIS ----------------------" -ForegroundColor DarkCyan
    Write-Host "    1.  Full System Health Report    4.  Battery Health Report" -ForegroundColor White
    Write-Host "    2.  Quick RAM & CPU Check        5.  Disk & Hardware Health" -ForegroundColor White
    Write-Host "    3.  Identify Heavy Processes     6.  Storage Space Analyzer" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- PERFORMANCE & TWEAKS ------------------------" -ForegroundColor DarkCyan
    Write-Host "    7.  Smart Startup Optimizer      9.  Optimize Windows Services" -ForegroundColor White
    Write-Host "    8.  Optimize RAM & Performance  10.  Fix Network Issues" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- PRIVACY & SECURITY --------------------------" -ForegroundColor DarkCyan
    Write-Host "   11.  Privacy & Telemetry Shield  12.  Windows Update Manager" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- CLEANING & DEBLOATING -----------------------" -ForegroundColor DarkCyan
    Write-Host "   13.  Deep Disk Clean             15.  Clean Old Restore Points" -ForegroundColor White
    Write-Host "   14.  Bloatware Uninstaller       16.  Delete Old Log Files" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- MAINTENANCE & REPAIRS -----------------------" -ForegroundColor DarkCyan
    Write-Host "   17.  Software Update (Winget)    19.  Create Restore Point" -ForegroundColor White
    Write-Host "   18.  Repair Windows (SFC+DISM)" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- AUTOMATION ----------------------------------" -ForegroundColor DarkCyan
    Write-Host "   20.  >>> RUN ALL OPTIMIZATIONS (Automated) <<<" -ForegroundColor Green
    Write-Host ""
    Write-Host "    0.  Exit" -ForegroundColor DarkGray
    Write-Host "    H.  Help (What does each option do?)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   +============================================+" -ForegroundColor DarkCyan
}

function Wait-KeyPress {
    if ($script:skipPause) { return }
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ============================================
# 1. FULL SYSTEM HEALTH REPORT
# ============================================
function Get-SystemInfo {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "FULL SYSTEM HEALTH REPORT" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $reportFile = "$desktopPath\System_Health_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
    
    # System Info
    Write-Log "[1/10] System Information..." "STEP"
    $computerInfo = Get-ComputerInfo -ErrorAction SilentlyContinue
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $output = @"
=== SYSTEM INFORMATION ===
OS: $($computerInfo.OsName)
Build: $($computerInfo.OsBuildNumber)
CPU: $($computerInfo.CsProcessors.Name)
Total RAM: $([math]::Round($computerInfo.CsTotalPhysicalMemory/1GB, 2)) GB
System Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes
Computer Name: $env:COMPUTERNAME
User: $env:USERNAME
Domain Joined: $($computerInfo.CsPartOfDomain)

"@
    Write-Host $output
    $output | Out-File -FilePath $reportFile
    
    # RAM Status
    Write-Log "[2/10] Memory Status..." "STEP"
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = $totalRAM - $freeRAM
    $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
    
    # Memory slot info
    $memSlots = Get-CimInstance Win32_PhysicalMemory
    $slotInfo = ""
    foreach ($slot in $memSlots) {
        $speed = if ($slot.Speed) { "$($slot.Speed) MHz" } else { "Unknown" }
        $slotInfo += "  Slot: $($slot.DeviceLocator) | $([math]::Round($slot.Capacity/1GB, 0)) GB | $speed | $($slot.Manufacturer)`n"
    }
    
    $output = @"
=== MEMORY STATUS ===
Total RAM: $totalRAM GB
Used RAM: $usedRAM GB ($ramPercent%)
Free RAM: $freeRAM GB
Status: $(if($ramPercent -lt 60){"Excellent"}elseif($ramPercent -lt 75){"Good"}elseif($ramPercent -lt 85){"Moderate"}else{"HIGH - Close apps!"})

RAM Modules:
$slotInfo
"@
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Top RAM Users
    Write-Log "[3/10] Top RAM Consumers..." "STEP"
    $output = "=== TOP 15 RAM USERS ===`n"
    Get-Process | Sort-Object WS -Descending | Select-Object -First 15 | ForEach-Object {
        $ramMB = [math]::Round($_.WS / 1MB, 2)
        $cpuTime = [math]::Round($_.CPU, 2)
        $output += "  $($_.ProcessName): $ramMB MB | CPU Time: $cpuTime s | PID: $($_.Id)`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # CPU Status
    Write-Log "[4/10] CPU Status..." "STEP"
    $cpu = Get-CimInstance Win32_Processor
    $cpuTemp = $null
    try {
        $thermalZone = Get-CimInstance MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction SilentlyContinue
        if ($thermalZone) {
            $cpuTemp = [math]::Round(($thermalZone.CurrentTemperature - 2732) / 10, 1)
        }
    }
    catch {}
    
    $output = @"
=== CPU STATUS ===
Processor: $($cpu.Name)
Cores: $($cpu.NumberOfCores) | Logical Processors: $($cpu.NumberOfLogicalProcessors)
Current Load: $($cpu.LoadPercentage)%
Max Clock: $($cpu.MaxClockSpeed) MHz
$(if($cpuTemp){"Temperature: $cpuTemp C"}else{"Temperature: Not available (requires hardware monitor)"})
Status: $(if($cpu.LoadPercentage -lt 30){"Idle"}elseif($cpu.LoadPercentage -lt 60){"Normal"}elseif($cpu.LoadPercentage -lt 85){"Busy"}else{"HEAVY LOAD"})

"@
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Disk Status
    Write-Log "[5/10] Disk Status..." "STEP"
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.Size -gt 0 }
    $output = "=== DISK STATUS ===`n"
    foreach ($vol in $volumes) {
        $percentFree = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 2)
        $percentUsed = 100 - $percentFree
        $bar = "[" + ($block.ToString() * [math]::Floor($percentUsed / 5)) + ($shade.ToString() * [math]::Ceiling($percentFree / 5)) + "]"
        $status = if ($percentFree -lt 10) { "CRITICAL" }elseif ($percentFree -lt 20) { "Low" }else { "OK" }
        $output += "  Drive $($vol.DriveLetter): $bar $percentUsed% used | $([math]::Round($vol.SizeRemaining/1GB, 2)) GB free / $([math]::Round($vol.Size/1GB, 2)) GB total | $status`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # GPU Info
    Write-Log "[6/10] GPU Information..." "STEP"
    $gpus = Get-CimInstance Win32_VideoController
    $output = "=== GPU STATUS ===`n"
    foreach ($gpu in $gpus) {
        $vram = [math]::Round($gpu.AdapterRAM / 1GB, 2)
        $vramStr = if ($vram -eq 0) { "System Shared" } else { "$vram GB" }
        $output += "  $($gpu.Name) | VRAM: $vramStr | Driver: $($gpu.DriverVersion) | Status: $($gpu.Status)`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Startup Programs
    Write-Log "[7/10] Startup Programs..." "STEP"
    $startupApps = Get-CimInstance Win32_StartupCommand
    $output = "=== STARTUP PROGRAMS ($($startupApps.Count) total) ===`n"
    foreach ($app in $startupApps) {
        $output += "  $($app.Name) | $($app.Location)`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Services
    Write-Log "[8/10] Critical Services..." "STEP"
    $criticalServices = @(
        @{Name = "SysMain"; Description = "Superfetch" },
        @{Name = "WSearch"; Description = "Windows Search" },
        @{Name = "DiagTrack"; Description = "Telemetry" },
        @{Name = "WinDefend"; Description = "Windows Defender" },
        @{Name = "Spooler"; Description = "Print Spooler" },
        @{Name = "wuauserv"; Description = "Windows Update" }
    )
    
    $output = "=== SERVICES STATUS ===`n"
    foreach ($svc in $criticalServices) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            $output += "  $($svc.Description): $($service.Status) / $($service.StartType)`n"
        }
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Network
    Write-Log "[9/10] Network Status..." "STEP"
    $output = "=== NETWORK STATUS ===`n"
    
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $adapters) {
        $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $dns = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue
        $output += "  Adapter: $($adapter.Name) | Speed: $($adapter.LinkSpeed) | IP: $($ipConfig.IPAddress) | DNS: $($dns.ServerAddresses -join ', ')`n"
    }
    
    try {
        # Note: -TimeoutSeconds is available in PS 7. For PS 5.1 we use a quick hack with WMI or accept the count 1 if offline, but -Count 1 is fast enough
        $ping = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
        $latencyProp = if ($ping[0].PSObject.Properties['Latency']) { 'Latency' } else { 'ResponseTime' }
        $avgLatency = [math]::Round(($ping | Measure-Object -Property $latencyProp -Average).Average, 2)
        $minLatency = ($ping | Measure-Object -Property $latencyProp -Minimum).Minimum
        $maxLatency = ($ping | Measure-Object -Property $latencyProp -Maximum).Maximum
        $output += "  Internet: Connected | Avg: ${avgLatency}ms | Min: ${minLatency}ms | Max: ${maxLatency}ms`n"
    }
    catch {
        $output += "  Internet: DISCONNECTED or BLOCKED`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    # Windows Activation Status
    Write-Log "[10/10] Windows License Status..." "STEP"
    $license = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" }
    $output = "=== WINDOWS LICENSE ===`n"
    if ($license) {
        $licStatus = switch ($license.LicenseStatus) {
            0 { "Unlicensed" }
            1 { "Licensed (Activated)" }
            2 { "Out of Box Grace" }
            3 { "Out of Tolerance Grace" }
            4 { "Non-Genuine Grace" }
            5 { "Notification" }
            default { "Unknown" }
        }
        $output += "  Status: $licStatus`n"
    }
    Write-Host $output
    $output | Out-File -FilePath $reportFile -Append
    
    Write-Host "`nFull report saved to: $reportFile" -ForegroundColor Green
    if (Get-ValidYN "Open report in Notepad?") {
        notepad $reportFile
    }
    Wait-KeyPress
}

# ============================================
# 2. QUICK RAM & CPU CHECK
# ============================================
function Get-QuickStatus {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "QUICK RAM & CPU CHECK" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = $totalRAM - $freeRAM
    $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
    
    $cpu = Get-CimInstance Win32_Processor
    
    # Visual bars
    $ramBar = "[" + ($block.ToString() * [math]::Floor($ramPercent / 5)) + ($shade.ToString() * [math]::Ceiling((100 - $ramPercent) / 5)) + "]"
    $cpuLoad = if ($cpu.LoadPercentage) { $cpu.LoadPercentage } else { 0 }
    $cpuBar = "[" + ($block.ToString() * [math]::Floor($cpuLoad / 5)) + ($shade.ToString() * [math]::Ceiling((100 - $cpuLoad) / 5)) + "]"
    
    $ramColor = if ($ramPercent -lt 60) { "Green" }elseif ($ramPercent -lt 80) { "Yellow" }else { "Red" }
    $cpuColor = if ($cpuLoad -lt 40) { "Green" }elseif ($cpuLoad -lt 75) { "Yellow" }else { "Red" }
    
    Write-Host "RAM: $ramBar $ramPercent% ($usedRAM / $totalRAM GB)" -ForegroundColor $ramColor
    Write-Host "CPU: $cpuBar $cpuLoad%" -ForegroundColor $cpuColor
    
    # Uptime
    $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    Write-Host "`nUptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Gray
    
    if ($uptime.Days -ge 7) {
        Write-Host "RECOMMENDATION: Restart your PC! It's been $($uptime.Days) days." -ForegroundColor Red
    }
    
    # Process count
    $procCount = (Get-Process).Count
    Write-Host "Running Processes: $procCount" -ForegroundColor $(if ($procCount -lt 150) { "Green" }elseif ($procCount -lt 250) { "Yellow" }else { "Red" })
    
    Wait-KeyPress
}

# ============================================
# 3. IDENTIFY HEAVY PROCESSES
# ============================================
function Get-HeavyProcesses {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "IDENTIFY HEAVY PROCESSES" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Top 15 RAM Users:" -ForegroundColor Yellow
    Write-Host ("-" * 70) -ForegroundColor Gray
    Write-Host ("  {0,-30} {1,10} {2,10} {3,8}" -f "Process", "RAM (MB)", "CPU (s)", "PID") -ForegroundColor Gray
    Write-Host ("-" * 70) -ForegroundColor Gray
    
    $topProcs = Get-Process | Sort-Object WS -Descending | Select-Object -First 15
    foreach ($proc in $topProcs) {
        $ramMB = [math]::Round($proc.WS / 1MB, 2)
        $cpuSec = [math]::Round($proc.CPU, 2)
        $color = if ($ramMB -gt 500) { "Red" }elseif ($ramMB -gt 200) { "Yellow" }else { "White" }
        Write-Host ("  {0,-30} {1,10} {2,10} {3,8}" -f $proc.ProcessName, $ramMB, $cpuSec, $proc.Id) -ForegroundColor $color
    }
    
    Write-Host "`nBrowser RAM Usage:" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor Gray
    $browsers = @("chrome", "msedge", "firefox", "brave", "opera", "vivaldi", "arc", "floorp", "waterfox", "tor", "zen", "comet")
    $totalBrowserRAM = 0
    foreach ($browser in $browsers) {
        $procs = Get-Process -Name $browser -ErrorAction SilentlyContinue
        if ($procs) {
            $browserRAM = [math]::Round(($procs | Measure-Object -Property WS -Sum).Sum / 1MB, 2)
            $totalBrowserRAM += $browserRAM
            Write-Host "  $($browser): $browserRAM MB ($($procs.Count) processes)" -ForegroundColor Cyan
        }
    }
    if ($totalBrowserRAM -gt 0) {
        Write-Host "  TOTAL Browser RAM: $totalBrowserRAM MB" -ForegroundColor Yellow
    }
    
    # Background services RAM
    Write-Host "`nBackground Services RAM:" -ForegroundColor Yellow
    Write-Host ("-" * 50) -ForegroundColor Gray
    $bgServices = @("SearchIndexer", "OneDrive", "Teams", "Spotify", "Discord", "Steam", "EpicWebHelper")
    foreach ($svc in $bgServices) {
        $procs = Get-Process -Name $svc -ErrorAction SilentlyContinue
        if ($procs) {
            $svcRAM = [math]::Round(($procs | Measure-Object -Property WS -Sum).Sum / 1MB, 2)
            Write-Host "  $($svc): $svcRAM MB" -ForegroundColor White
        }
    }
    
    # Kill option
    Write-Host "`nWould you like to kill a process? Enter PID (or 0 to skip): " -ForegroundColor Yellow -NoNewline
    $killPID = Read-Host
    if ($killPID -ne "0" -and $killPID -ne "") {
        try {
            $procToKill = Get-Process -Id $killPID -ErrorAction Stop
            if ($procToKill.ProcessName -match '^(System|smss|csrss|wininit|services|explorer|lsass|svchost)$') {
                Write-Log "Cannot kill critical system process: $($procToKill.ProcessName)" "ERROR"
            }
            elseif (Get-ValidYN "Kill '$($procToKill.ProcessName)' (PID: $killPID)?") {
                Stop-Process -Id $killPID -Force -ErrorAction Stop
                Write-Log "Killed process: $($procToKill.ProcessName) (PID: $killPID)" "SUCCESS"
            }
        }
        catch {
            Write-Log "Could not kill PID $killPID : $($_.Exception.Message)" "ERROR"
        }
    }
    
    Wait-KeyPress
}

# ============================================
# 4. BATTERY HEALTH REPORT
# ============================================
function Get-BatteryHealth {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "BATTERY HEALTH REPORT" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $reportPath = "$desktopPath\battery-report.html"
    
    Write-Log "Generating battery report..." "STEP"
    try {
        powercfg /batteryreport /output $reportPath 2>$null
        
        if (Test-Path $reportPath) {
            Write-Log "Battery report generated!" "SUCCESS"
            
            # Quick battery stats
            $battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
            if ($battery) {
                Write-Host "`n  Battery Status: $($battery.Status)" -ForegroundColor White
                Write-Host "  Charge Remaining: $($battery.EstimatedChargeRemaining)%" -ForegroundColor $(if ($battery.EstimatedChargeRemaining -gt 50) { "Green" }elseif ($battery.EstimatedChargeRemaining -gt 20) { "Yellow" }else { "Red" })
                
                $statusText = switch ($battery.BatteryStatus) {
                    1 { "Discharging" }
                    2 { "AC Connected" }
                    3 { "Fully Charged" }
                    4 { "Low" }
                    5 { "Critical" }
                    6 { "Charging" }
                    7 { "Charging - High" }
                    8 { "Charging - Low" }
                    9 { "Charging - Critical" }
                    default { "Unknown" }
                }
                Write-Host "  Power Status: $statusText" -ForegroundColor White
                
                if ($battery.EstimatedRunTime -and $battery.EstimatedRunTime -ne 71582788) {
                    $hours = [math]::Floor($battery.EstimatedRunTime / 60)
                    $mins = $battery.EstimatedRunTime % 60
                    Write-Host "  Estimated Runtime: ${hours}h ${mins}m" -ForegroundColor White
                }
            }
            else {
                Write-Host "`n  No battery detected (Desktop PC?)" -ForegroundColor Gray
            }
            
            Write-Host "`n  Full report saved to: $reportPath" -ForegroundColor Green
            if (Get-ValidYN "  Open report in browser?") {
                Start-Process $reportPath
            }
        }
    }
    catch {
        Write-Log "Battery report generation failed: $($_.Exception.Message)" "ERROR"
    }
    
    # Power configuration tips
    Write-Host "`nPower Optimization Tips:" -ForegroundColor Yellow
    Write-Host "  - Use 'Balanced' power plan for battery life" -ForegroundColor Gray
    Write-Host "  - Use 'High Performance' when plugged in" -ForegroundColor Gray
    Write-Host "  - Keep battery between 20-80% for longevity" -ForegroundColor Gray
    
    Wait-KeyPress
}

# ============================================
# 5. DISK HEALTH (S.M.A.R.T.)
# ============================================
function Get-DiskHealth {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "DISK HEALTH (S.M.A.R.T.)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Log "Checking disk health..." "STEP"
    
    # CPU Temperature check (merged into hardware health)
    Write-Log "Checking system temperatures..." "STEP"
    try {
        $thermal = Get-CimInstance MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction Stop
        foreach ($zone in $thermal) {
            $cpuTemp = [math]::Round(($zone.CurrentTemperature - 2732) / 10, 1)
            $tempColor = if ($cpuTemp -gt 85) { "Red" } elseif ($cpuTemp -gt 70) { "Yellow" } else { "Green" }
            Write-Host "  CPU Temperature: ${cpuTemp} C" -ForegroundColor $tempColor
            if ($cpuTemp -gt 85) {
                Write-Host "    WARNING: CPU is running hot! Check cooling/ventilation." -ForegroundColor Red
            }
            elseif ($cpuTemp -gt 70) {
                Write-Host "    Note: Elevated temperature. Ensure vents are not blocked." -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "  CPU Temperature: Sensor not accessible (common on some hardware)" -ForegroundColor DarkGray
    }
    Write-Host ""
    
    # Physical disk info
    try {
        $disks = @(Get-PhysicalDisk -ErrorAction Stop)
        foreach ($disk in $disks) {
            $healthColor = switch ($disk.HealthStatus) {
                "Healthy" { "Green" }
                "Warning" { "Yellow" }
                "Unhealthy" { "Red" }
                default { "White" }
            }
            
            Write-Host "  Disk $($disk.DeviceId): $($disk.FriendlyName)" -ForegroundColor White
            Write-Host "    Type: $($disk.MediaType)" -ForegroundColor Gray
            Write-Host "    Size: $([math]::Round($disk.Size/1GB, 2)) GB" -ForegroundColor Gray
            Write-Host "    Health: $($disk.HealthStatus)" -ForegroundColor $healthColor
            Write-Host "    Operational: $($disk.OperationalStatus)" -ForegroundColor Gray
            
            if ($disk.HealthStatus -ne "Healthy") {
                Write-Host "    [!] WARNING: Disk health is not optimal! Back up data immediately!" -ForegroundColor Red
            }
            Write-Host ""
        }
    }
    catch {
        Write-Host "  Could not retrieve physical disk info (common on some VMs/RAID)" -ForegroundColor DarkGray
    }
    
    # Disk reliability data
    Write-Log "Checking disk reliability counters..." "STEP"
    try {
        $reliability = Get-PhysicalDisk | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
        if ($reliability) {
            foreach ($rel in $reliability) {
                Write-Host "  Reliability Counters (Device $($rel.DeviceId)):" -ForegroundColor Yellow
                
                # Check each value for null
                $rErr = if ($null -ne $rel.ReadErrorsTotal) { $rel.ReadErrorsTotal } else { "N/A" }
                $wErr = if ($null -ne $rel.WriteErrorsTotal) { $rel.WriteErrorsTotal } else { "N/A" }
                $temp = if ($null -ne $rel.Temperature) { $rel.Temperature } else { "N/A" }
                $wear = if ($null -ne $rel.Wear) { $rel.Wear } else { "N/A" }
                $hours = if ($null -ne $rel.PowerOnHours) { $rel.PowerOnHours } else { "N/A" }

                # Determine colors
                $rColor = if ($rErr -eq 0) { "Green" } elseif ($rErr -eq "N/A") { "Gray" } else { "Red" }
                $wColor = if ($wErr -eq 0) { "Green" } elseif ($wErr -eq "N/A") { "Gray" } else { "Red" }
                
                $tColor = "Gray"
                if ($temp -ne "N/A") {
                    $tColor = if ($temp -lt 50) { "Green" } elseif ($temp -lt 60) { "Yellow" } else { "Red" }
                }

                $wearColor = "Gray"
                if ($wear -ne "N/A") {
                    $wearColor = if ($wear -lt 20) { "Green" } elseif ($wear -lt 50) { "Yellow" } else { "Red" }
                }

                Write-Host "    Read Errors: $rErr" -ForegroundColor $rColor
                Write-Host "    Write Errors: $wErr" -ForegroundColor $wColor
                Write-Host "    Temperature: $temp C" -ForegroundColor $tColor
                Write-Host "    Wear: $wear%" -ForegroundColor $wearColor
                Write-Host "    Power On Hours: $hours" -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host "  Detailed reliability data not available" -ForegroundColor Gray
    }
    
    # Volume fragmentation analysis
    Write-Log "Checking volume optimization status..." "STEP"
    $volumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.Size -gt 0 -and $_.DriveType -eq "Fixed" }
    foreach ($vol in $volumes) {
        try {
            Optimize-Volume -DriveLetter $vol.DriveLetter -Analyze -ErrorAction SilentlyContinue | Out-Null
            Write-Host "`n  Drive $($vol.DriveLetter): File System: $($vol.FileSystem)" -ForegroundColor White
        }
        catch {}
    }
    
    Wait-KeyPress
}

# ============================================
# 6. STORAGE SPACE ANALYZER
# ============================================
function Get-StorageAnalysis {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "STORAGE SPACE ANALYZER" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Drive overview
    Write-Log "Analyzing disk space usage..." "STEP"
    $volume = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    if ($volume) {
        $totalGB = [math]::Round($volume.Size / 1GB, 1)
        $usedGB = [math]::Round(($volume.Size - $volume.SizeRemaining) / 1GB, 1)
        $freeGB = [math]::Round($volume.SizeRemaining / 1GB, 1)
        $usedPct = [math]::Round(($usedGB / $totalGB) * 100)
        
        $barFill = [math]::Floor($usedPct / 5)
        $bar = $block.ToString() * $barFill + $shade.ToString() * (20 - $barFill)
        $barClr = if ($usedPct -lt 70) { "Green" } elseif ($usedPct -lt 85) { "Yellow" } else { "Red" }
        
        Write-Host "  Drive C: [$bar] $usedPct% used" -ForegroundColor $barClr
        Write-Host "  Total: $totalGB GB  |  Used: $usedGB GB  |  Free: $freeGB GB" -ForegroundColor Gray
        Write-Host ""
    }
    
    # Scan key folders
    Write-Host "  Scanning folders (this may take 1-2 minutes)...`n" -ForegroundColor Gray
    
    $foldersToScan = @(
        @{Path = "$env:USERPROFILE\Downloads"; Label = "Downloads" },
        @{Path = "$env:USERPROFILE\Documents"; Label = "Documents" },
        @{Path = "$env:USERPROFILE\Videos"; Label = "Videos" },
        @{Path = "$env:USERPROFILE\Pictures"; Label = "Pictures" },
        @{Path = "$env:USERPROFILE\Desktop"; Label = "Desktop" },
        @{Path = "$env:USERPROFILE\Music"; Label = "Music" },
        @{Path = "$env:LOCALAPPDATA\Temp"; Label = "Temp Files" },
        @{Path = "$env:WINDIR\Temp"; Label = "Windows Temp" },
        @{Path = "$env:WINDIR\SoftwareDistribution"; Label = "Windows Update Cache" },
        @{Path = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"; Label = "Thumbnail Cache" },
        @{Path = "$env:LOCALAPPDATA\Google\Chrome\User Data"; Label = "Chrome Data" },
        @{Path = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"; Label = "Edge Data" }
    )
    
    $results = @()
    foreach ($folder in $foldersToScan) {
        if (Test-Path $folder.Path) {
            try {
                $size = (Get-ChildItem -Path $folder.Path -Recurse -File -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                if (-not $size) { $size = 0 }
                $results += [PSCustomObject]@{
                    Label  = $folder.Label
                    Path   = $folder.Path
                    SizeGB = [math]::Round($size / 1GB, 2)
                    SizeMB = [math]::Round($size / 1MB, 0)
                }
            }
            catch {}
        }
    }
    
    # Sort by size and display with visual bars
    $results = $results | Sort-Object SizeGB -Descending
    $maxSize = ($results | Select-Object -First 1).SizeGB
    if (-not $maxSize -or $maxSize -eq 0) { $maxSize = 1 }
    
    Write-Host ("  {0,-25} {1,10}  {2}" -f "FOLDER", "SIZE", "") -ForegroundColor DarkCyan
    Write-Host "  $("-" * 55)" -ForegroundColor DarkGray
    
    foreach ($r in $results) {
        if ($r.SizeMB -lt 1) { continue }  # Skip empty folders
        
        $barLen = [math]::Max(1, [math]::Floor(($r.SizeGB / $maxSize) * 20))
        $sizeBar = $block.ToString() * $barLen
        
        $sizeStr = if ($r.SizeGB -ge 1) { "$($r.SizeGB) GB" } else { "$($r.SizeMB) MB" }
        $color = if ($r.SizeGB -gt 10) { "Red" } elseif ($r.SizeGB -gt 2) { "Yellow" } else { "White" }
        
        Write-Host ("  {0,-25} {1,10}  " -f $r.Label, $sizeStr) -NoNewline -ForegroundColor $color
        Write-Host $sizeBar -ForegroundColor $color
    }
    
    # Recommendations
    Write-Host "`n  Recommendations:" -ForegroundColor Yellow
    
    $downloads = $results | Where-Object { $_.Label -eq "Downloads" }
    if ($downloads -and $downloads.SizeGB -gt 2) {
        Write-Host "    - Downloads folder is $($downloads.SizeGB) GB. Review and delete old files." -ForegroundColor White
    }
    
    $tempTotal = ($results | Where-Object { $_.Label -like "*Temp*" -or $_.Label -like "*Cache*" } | Measure-Object -Property SizeMB -Sum).Sum
    if ($tempTotal -gt 500) {
        $tempGB = [math]::Round($tempTotal / 1024, 1)
        Write-Host "    - Temp/cache files total ~$tempGB GB. Run Deep Disk Clean (Option 13)." -ForegroundColor White
    }
    
    $videos = $results | Where-Object { $_.Label -eq "Videos" }
    if ($videos -and $videos.SizeGB -gt 10) {
        Write-Host "    - Videos folder is $($videos.SizeGB) GB. Move to external drive?" -ForegroundColor White
    }
    
    $browserData = ($results | Where-Object { $_.Label -like "*Data" } | Measure-Object -Property SizeMB -Sum).Sum
    if ($browserData -gt 1000) {
        Write-Host "    - Browser data is $([math]::Round($browserData/1024, 1)) GB. Clear caches via Option 13." -ForegroundColor White
    }
    
    if ($volume -and $null -ne $freeGB) {
        if ($freeGB -lt 20) {
            Write-Host "    - LOW DISK SPACE! Only $freeGB GB free. Take action soon." -ForegroundColor Red
        }
        else {
            Write-Host "    - Disk space looks healthy." -ForegroundColor Green
        }
    }
    
    Wait-KeyPress
}

# ============================================
# 7. SMART STARTUP OPTIMIZER
# ============================================
function Optimize-Startup {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "SMART STARTUP OPTIMIZER" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # ── Protected patterns: drivers, security, system essentials ──
    # These will NEVER be disabled regardless of user choice
    $protectedPatterns = @(
        # Windows Security & Antivirus
        "SecurityHealth*", "Windows Defender*", "WinDefend*", "WindowsSecurity*",
        "McAfee*", "mcpltui*", "McUICnt*",
        "Norton*", "NortonLifeLock*",
        "Avast*", "AvastUI*", "aswRunDll*",
        "AVG*", "AVGUI*",
        "Kaspersky*", "KL*", "avp*",
        "Bitdefender*", "bdagent*", "bdservicehost*",
        "Malwarebytes*", "MBAMTray*",
        "ESET*", "egui*", "ekrn*",
        "Sophos*", "SAVAdminService*",
        "TrendMicro*", "OfficeScan*",
        "Webroot*", "WRSA*",
        "Comodo*",
        "F-Secure*",
        "BullGuard*",
        # Audio drivers
        "RtHDV*", "Realtek*", "RtkAudU*", "RtkNGUI*",
        "WavesSvc*", "Waves*",
        "IDT*", "cAVS*", "MaxxAudio*",
        "DolbyDAX*", "Dolby*",
        "Conexant*", "CxUtilSvc*",
        "SoundBlaster*", "Creative*Audio*",
        "Bang*Olufsen*",
        # GPU drivers
        "NVDisplay*", "NVIDIA*", "nv*tray*", "NvBackend*",
        "AMD*Radeon*", "Radeon*", "StartCN*", "cn*Cmd*",
        "igfx*", "HKCMD*", "Intel*Graphics*", "IntelGFX*",
        # Touchpad / Input drivers
        "ETD*", "Synaptics*", "ELAN*", "SynTP*",
        "Precision*Touch*", "Dell*Touch*",
        "Wacom*", "WTablet*",
        # Keyboard / Lighting (OEM)
        "HotKey*", "Fn*Key*",
        # Printer essentials (core service, not spooler bloat)
        "HPStatus*Monitor*",
        # System essentials
        "ctfmon*", "SecurityRegistration*",
        "VMware*", "VBox*",
        "Hyper-V*",
        "WindowsTerminal*",
        "PowerShell*",
        # Docking / Display management
        "DisplayLink*",
        "Thunderbolt*"
    )
    
    # ── Known non-essential apps with descriptions and categories ──
    # Organized by category for easy maintenance
    $knownNonEssential = @(
        # ─── Communication ───
        @{Pattern = "Discord"; Desc = "Discord"; Category = "Communication" },
        @{Pattern = "DiscordUpdate*"; Desc = "Discord Updater"; Category = "Updater" },
        @{Pattern = "Teams*"; Desc = "Microsoft Teams"; Category = "Communication" },
        @{Pattern = "com.squirrel.Teams*"; Desc = "Microsoft Teams"; Category = "Communication" },
        @{Pattern = "Slack*"; Desc = "Slack"; Category = "Communication" },
        @{Pattern = "Skype*"; Desc = "Skype"; Category = "Communication" },
        @{Pattern = "Zoom*"; Desc = "Zoom"; Category = "Communication" },
        @{Pattern = "Telegram*"; Desc = "Telegram Desktop"; Category = "Communication" },
        @{Pattern = "Signal*"; Desc = "Signal Messenger"; Category = "Communication" },
        @{Pattern = "WhatsApp*"; Desc = "WhatsApp Desktop"; Category = "Communication" },
        @{Pattern = "Viber*"; Desc = "Viber"; Category = "Communication" },
        @{Pattern = "Webex*"; Desc = "Cisco Webex"; Category = "Communication" },
        @{Pattern = "RingCentral*"; Desc = "RingCentral"; Category = "Communication" },
        @{Pattern = "GoTo*"; Desc = "GoTo Meeting"; Category = "Communication" },
        @{Pattern = "Franz*"; Desc = "Franz Messenger"; Category = "Communication" },
        @{Pattern = "Rambox*"; Desc = "Rambox"; Category = "Communication" },

        # ─── Gaming ───
        @{Pattern = "Steam*"; Desc = "Steam Client"; Category = "Gaming" },
        @{Pattern = "EpicGames*"; Desc = "Epic Games Launcher"; Category = "Gaming" },
        @{Pattern = "EpicWebHelper*"; Desc = "Epic Web Helper"; Category = "Gaming" },
        @{Pattern = "Origin*"; Desc = "EA Origin / EA App"; Category = "Gaming" },
        @{Pattern = "EADesktop*"; Desc = "EA Desktop App"; Category = "Gaming" },
        @{Pattern = "EABackgroundService*"; Desc = "EA Background Service"; Category = "Gaming" },
        @{Pattern = "GOGGalaxy*"; Desc = "GOG Galaxy"; Category = "Gaming" },
        @{Pattern = "Ubisoft*"; Desc = "Ubisoft Connect"; Category = "Gaming" },
        @{Pattern = "RiotVanguard*"; Desc = "Riot Vanguard Anti-Cheat"; Category = "Gaming" },
        @{Pattern = "Riot*Client*"; Desc = "Riot Client"; Category = "Gaming" },
        @{Pattern = "Overwolf*"; Desc = "Overwolf Overlay"; Category = "Gaming" },
        @{Pattern = "Battle.net*"; Desc = "Blizzard Battle.net"; Category = "Gaming" },
        @{Pattern = "Blizzard*"; Desc = "Blizzard App"; Category = "Gaming" },
        @{Pattern = "Bethesda*"; Desc = "Bethesda Launcher"; Category = "Gaming" },
        @{Pattern = "Rockstar*"; Desc = "Rockstar Games Launcher"; Category = "Gaming" },
        @{Pattern = "AmazonGames*"; Desc = "Amazon Games"; Category = "Gaming" },
        @{Pattern = "Playnite*"; Desc = "Playnite Game Launcher"; Category = "Gaming" },
        @{Pattern = "GameBar*"; Desc = "Xbox Game Bar"; Category = "Gaming" },

        # ─── Entertainment & Media ───
        @{Pattern = "Spotify*"; Desc = "Spotify"; Category = "Entertainment" },
        @{Pattern = "iTunesHelper*"; Desc = "iTunes Helper"; Category = "Entertainment" },
        @{Pattern = "iTunes*"; Desc = "iTunes"; Category = "Entertainment" },
        @{Pattern = "RealPlayer*"; Desc = "RealPlayer"; Category = "Entertainment" },
        @{Pattern = "VLC*"; Desc = "VLC Media Player"; Category = "Entertainment" },
        @{Pattern = "Plex*"; Desc = "Plex Media Server"; Category = "Entertainment" },
        @{Pattern = "Amazon Music*"; Desc = "Amazon Music"; Category = "Entertainment" },
        @{Pattern = "Deezer*"; Desc = "Deezer"; Category = "Entertainment" },
        @{Pattern = "Tidal*"; Desc = "Tidal Music"; Category = "Entertainment" },

        # ─── Cloud Sync ───
        @{Pattern = "OneDrive*"; Desc = "Microsoft OneDrive"; Category = "Cloud Sync" },
        @{Pattern = "Dropbox"; Desc = "Dropbox"; Category = "Cloud Sync" },
        @{Pattern = "GoogleDrive*"; Desc = "Google Drive"; Category = "Cloud Sync" },
        @{Pattern = "iCloud*"; Desc = "Apple iCloud"; Category = "Cloud Sync" },
        @{Pattern = "*BoxSync*"; Desc = "Box Sync"; Category = "Cloud Sync" },
        @{Pattern = "MEGAsync*"; Desc = "MEGA Cloud Sync"; Category = "Cloud Sync" },
        @{Pattern = "pCloud*"; Desc = "pCloud Drive"; Category = "Cloud Sync" },
        @{Pattern = "Syncthing*"; Desc = "Syncthing"; Category = "Cloud Sync" },
        @{Pattern = "Nextcloud*"; Desc = "Nextcloud Client"; Category = "Cloud Sync" },
        @{Pattern = "Resilio*"; Desc = "Resilio Sync"; Category = "Cloud Sync" },

        # ─── Updaters (almost always safe to disable) ───
        @{Pattern = "Adobe*Update*"; Desc = "Adobe Updater"; Category = "Updater" },
        @{Pattern = "AdobeAAM*"; Desc = "Adobe Application Manager"; Category = "Updater" },
        @{Pattern = "CCXProcess*"; Desc = "Adobe Creative Cloud"; Category = "Updater" },
        @{Pattern = "AdobeGC*"; Desc = "Adobe Genuine Service"; Category = "Updater" },
        @{Pattern = "GoogleUpdate*"; Desc = "Google Update Service"; Category = "Updater" },
        @{Pattern = "DropboxUpdate*"; Desc = "Dropbox Updater"; Category = "Updater" },
        @{Pattern = "Opera*Assistant*"; Desc = "Opera Browser Assistant"; Category = "Updater" },
        @{Pattern = "BraveSoftware*"; Desc = "Brave Browser Helper"; Category = "Updater" },
        @{Pattern = "Vivaldi*"; Desc = "Vivaldi Browser Helper"; Category = "Updater" },
        @{Pattern = "CCleanerBrowser*"; Desc = "CCleaner Browser"; Category = "Updater" },
        @{Pattern = "Microsoft*Update*"; Desc = "Microsoft Update Helper"; Category = "Updater" },
        @{Pattern = "Java*Update*"; Desc = "Java Update Scheduler"; Category = "Updater" },
        @{Pattern = "jusched*"; Desc = "Java Update Scheduler"; Category = "Updater" },
        @{Pattern = "DellUpdate*"; Desc = "Dell Update Service"; Category = "Updater" },
        @{Pattern = "HPUpdate*"; Desc = "HP Update Service"; Category = "Updater" },
        @{Pattern = "LenovoVantage*"; Desc = "Lenovo Vantage"; Category = "Updater" },
        @{Pattern = "Lenovo*Update*"; Desc = "Lenovo Update Service"; Category = "Updater" },
        @{Pattern = "ASUSUpdate*"; Desc = "ASUS Update Service"; Category = "Updater" },

        # ─── Productivity ───
        @{Pattern = "Grammarly*"; Desc = "Grammarly"; Category = "Productivity" },
        @{Pattern = "Canva*"; Desc = "Canva"; Category = "Productivity" },
        @{Pattern = "Notion*"; Desc = "Notion"; Category = "Productivity" },
        @{Pattern = "Todoist*"; Desc = "Todoist"; Category = "Productivity" },
        @{Pattern = "Evernote*"; Desc = "Evernote"; Category = "Productivity" },
        @{Pattern = "OneNote*"; Desc = "Microsoft OneNote"; Category = "Productivity" },
        @{Pattern = "Trello*"; Desc = "Trello"; Category = "Productivity" },
        @{Pattern = "Asana*"; Desc = "Asana"; Category = "Productivity" },
        @{Pattern = "ClickUp*"; Desc = "ClickUp"; Category = "Productivity" },
        @{Pattern = "Obsidian*"; Desc = "Obsidian Notes"; Category = "Productivity" },

        # ─── Password Managers ───
        @{Pattern = "1Password*"; Desc = "1Password"; Category = "Password Manager" },
        @{Pattern = "LastPass*"; Desc = "LastPass"; Category = "Password Manager" },
        @{Pattern = "Bitwarden*"; Desc = "Bitwarden"; Category = "Password Manager" },
        @{Pattern = "Dashlane*"; Desc = "Dashlane"; Category = "Password Manager" },
        @{Pattern = "KeePass*"; Desc = "KeePass"; Category = "Password Manager" },
        @{Pattern = "NordPass*"; Desc = "NordPass"; Category = "Password Manager" },
        @{Pattern = "RoboForm*"; Desc = "RoboForm"; Category = "Password Manager" },
        @{Pattern = "Keeper*"; Desc = "Keeper Password Manager"; Category = "Password Manager" },

        # ─── VPN Services ───
        @{Pattern = "NordVPN*"; Desc = "NordVPN"; Category = "VPN" },
        @{Pattern = "ExpressVPN*"; Desc = "ExpressVPN"; Category = "VPN" },
        @{Pattern = "Windscribe*"; Desc = "Windscribe VPN"; Category = "VPN" },
        @{Pattern = "ProtonVPN*"; Desc = "ProtonVPN"; Category = "VPN" },
        @{Pattern = "Surfshark*"; Desc = "Surfshark VPN"; Category = "VPN" },
        @{Pattern = "CyberGhost*"; Desc = "CyberGhost VPN"; Category = "VPN" },
        @{Pattern = "pia-client*"; Desc = "Private Internet Access"; Category = "VPN" },
        @{Pattern = "PrivateInternetAccess*"; Desc = "Private Internet Access"; Category = "VPN" },
        @{Pattern = "Mullvad*"; Desc = "Mullvad VPN"; Category = "VPN" },
        @{Pattern = "TunnelBear*"; Desc = "TunnelBear VPN"; Category = "VPN" },
        @{Pattern = "Hotspot*Shield*"; Desc = "Hotspot Shield VPN"; Category = "VPN" },

        # ─── Peripherals & Hardware Utilities ───
        @{Pattern = "LogiOptions*"; Desc = "Logitech Options+"; Category = "Peripheral" },
        @{Pattern = "LogiBolt*"; Desc = "Logitech Bolt"; Category = "Peripheral" },
        @{Pattern = "LogiTune*"; Desc = "Logitech Tune"; Category = "Peripheral" },
        @{Pattern = "GHUB*"; Desc = "Logitech G HUB"; Category = "Peripheral" },
        @{Pattern = "iCUE*"; Desc = "Corsair iCUE"; Category = "Peripheral" },
        @{Pattern = "Corsair*"; Desc = "Corsair Software"; Category = "Peripheral" },
        @{Pattern = "Razer*"; Desc = "Razer Synapse"; Category = "Peripheral" },
        @{Pattern = "SteelSeries*"; Desc = "SteelSeries GG/Engine"; Category = "Peripheral" },
        @{Pattern = "HyperX*"; Desc = "HyperX NGENUITY"; Category = "Peripheral" },
        @{Pattern = "NZXT*"; Desc = "NZXT CAM"; Category = "Peripheral" },
        @{Pattern = "Elgato*"; Desc = "Elgato Software"; Category = "Peripheral" },
        @{Pattern = "StreamDeck*"; Desc = "Elgato Stream Deck"; Category = "Peripheral" },
        @{Pattern = "JabraDirectSetup*"; Desc = "Jabra Direct"; Category = "Peripheral" },
        @{Pattern = "Jabra*"; Desc = "Jabra Software"; Category = "Peripheral" },
        @{Pattern = "Poly*"; Desc = "Poly (Plantronics)"; Category = "Peripheral" },
        @{Pattern = "Sonos*"; Desc = "Sonos Controller"; Category = "Peripheral" },

        # ─── Creative & Streaming ───
        @{Pattern = "Figma*"; Desc = "Figma Agent"; Category = "Creative" },
        @{Pattern = "OBS*"; Desc = "OBS Studio"; Category = "Creative" },
        @{Pattern = "Streamlabs*"; Desc = "Streamlabs Desktop"; Category = "Creative" },
        @{Pattern = "XSplit*"; Desc = "XSplit Broadcaster"; Category = "Creative" },
        @{Pattern = "Audacity*"; Desc = "Audacity"; Category = "Creative" },
        @{Pattern = "GIMP*"; Desc = "GIMP Image Editor"; Category = "Creative" },
        @{Pattern = "Blender*"; Desc = "Blender 3D"; Category = "Creative" },
        @{Pattern = "DaVinci*"; Desc = "DaVinci Resolve"; Category = "Creative" },

        # ─── Dev Tools ───
        @{Pattern = "Docker*"; Desc = "Docker Desktop"; Category = "Dev Tool" },
        @{Pattern = "Postman*"; Desc = "Postman API Client"; Category = "Dev Tool" },
        @{Pattern = "GitHubDesktop*"; Desc = "GitHub Desktop"; Category = "Dev Tool" },
        @{Pattern = "SourceTree*"; Desc = "SourceTree Git Client"; Category = "Dev Tool" },
        @{Pattern = "Insomnia*"; Desc = "Insomnia REST Client"; Category = "Dev Tool" },

        # ─── Browser Auto-Launch ───
        @{Pattern = "MicrosoftEdge*Auto*"; Desc = "Edge Auto-Launch"; Category = "Browser" },
        @{Pattern = "Google*Chrome*Auto*"; Desc = "Chrome Auto-Launch"; Category = "Browser" },
        @{Pattern = "Firefox*Auto*"; Desc = "Firefox Auto-Launch"; Category = "Browser" },

        # ─── System Utilities / Bloat ───
        @{Pattern = "Cortana*"; Desc = "Cortana"; Category = "Other" },
        @{Pattern = "YourPhone*"; Desc = "Phone Link"; Category = "Other" },
        @{Pattern = "PhoneLink*"; Desc = "Phone Link"; Category = "Other" },
        @{Pattern = "QuickTime*"; Desc = "QuickTime"; Category = "Other" },
        @{Pattern = "CyberLink*"; Desc = "CyberLink Media"; Category = "Other" },
        @{Pattern = "NahimicService*"; Desc = "Nahimic (audio bloatware)"; Category = "Other" },
        @{Pattern = "Nahimic*"; Desc = "Nahimic Companion"; Category = "Other" },
        @{Pattern = "WMPNetworkSvc*"; Desc = "WMP Network Sharing"; Category = "Other" },
        @{Pattern = "CCleaner*"; Desc = "CCleaner"; Category = "Other" },
        @{Pattern = "IObit*"; Desc = "IObit Software"; Category = "Other" },
        @{Pattern = "Advanced SystemCare*"; Desc = "Advanced SystemCare"; Category = "Other" },
        @{Pattern = "WiseCare*"; Desc = "Wise Care 365"; Category = "Other" },
        @{Pattern = "WiseClean*"; Desc = "Wise Disk Cleaner"; Category = "Other" },
        @{Pattern = "Glary*"; Desc = "Glary Utilities"; Category = "Other" },
        @{Pattern = "WinZip*"; Desc = "WinZip"; Category = "Other" },
        @{Pattern = "WinRAR*"; Desc = "WinRAR"; Category = "Other" },
        @{Pattern = "PowerISO*"; Desc = "PowerISO"; Category = "Other" },
        @{Pattern = "Acronis*"; Desc = "Acronis True Image"; Category = "Other" },
        @{Pattern = "EaseUS*"; Desc = "EaseUS Software"; Category = "Other" },
        @{Pattern = "MiniTool*"; Desc = "MiniTool Software"; Category = "Other" },
        @{Pattern = "Wondershare*"; Desc = "Wondershare Software"; Category = "Other" },
        @{Pattern = "CyberReason*"; Desc = "CyberReason (if not corporate)"; Category = "Other" },

        # ─── OEM Bloatware ───
        @{Pattern = "DellSupportAssist*"; Desc = "Dell SupportAssist"; Category = "OEM Bloat" },
        @{Pattern = "DellOptimizer*"; Desc = "Dell Optimizer"; Category = "OEM Bloat" },
        @{Pattern = "Dell*Inc*"; Desc = "Dell Software"; Category = "OEM Bloat" },
        @{Pattern = "HPJumpStart*"; Desc = "HP JumpStart"; Category = "OEM Bloat" },
        @{Pattern = "HPSupportSolutions*"; Desc = "HP Support Solutions"; Category = "OEM Bloat" },
        @{Pattern = "HPOmenCommander*"; Desc = "HP OMEN Gaming Hub"; Category = "OEM Bloat" },
        @{Pattern = "AsusSoftwareManager*"; Desc = "ASUS Software Manager"; Category = "OEM Bloat" },
        @{Pattern = "ArmouryCrate*"; Desc = "ASUS Armoury Crate"; Category = "OEM Bloat" },
        @{Pattern = "MyASUS*"; Desc = "MyASUS"; Category = "OEM Bloat" },
        @{Pattern = "LenovoNow*"; Desc = "Lenovo Now"; Category = "OEM Bloat" },
        @{Pattern = "AcerQuickAccess*"; Desc = "Acer Quick Access"; Category = "OEM Bloat" },
        @{Pattern = "AcerCare*"; Desc = "Acer Care Center"; Category = "OEM Bloat" },
        @{Pattern = "MSI*Center*"; Desc = "MSI Center"; Category = "OEM Bloat" },
        @{Pattern = "DragonCenter*"; Desc = "MSI Dragon Center"; Category = "OEM Bloat" },
        @{Pattern = "Samsung*Magician*"; Desc = "Samsung Magician"; Category = "OEM Bloat" },
        @{Pattern = "Samsung*Settings*"; Desc = "Samsung Settings"; Category = "OEM Bloat" },

        # ─── Remote Desktop / Support ───
        @{Pattern = "TeamViewer*"; Desc = "TeamViewer"; Category = "Remote" },
        @{Pattern = "AnyDesk*"; Desc = "AnyDesk"; Category = "Remote" },
        @{Pattern = "Parsec*"; Desc = "Parsec Remote Desktop"; Category = "Remote" },
        @{Pattern = "RustDesk*"; Desc = "RustDesk"; Category = "Remote" },
        @{Pattern = "Chrome*Remote*Desktop*"; Desc = "Chrome Remote Desktop"; Category = "Remote" }
    )
    
    # ── Phase 1: Scan all startup entries ──
    Write-Log "[1/3] Scanning startup entries..." "STEP"
    
    $runKeys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    $allEntries = @()
    foreach ($key in $runKeys) {
        if (!(Test-Path $key)) { continue }
        $entries = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        if (!$entries) { continue }
        $props = $entries.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" }
        foreach ($prop in $props) {
            $allEntries += [PSCustomObject]@{
                Name   = $prop.Name
                Value  = [string]$prop.Value
                Source = $key
            }
        }
    }
    
    # Also fetch active scheduled tasks for later
    $activeTasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.State -ne "Disabled" }
    
    if ($allEntries.Count -eq 0) {
        Write-Host "  No startup entries found in registry." -ForegroundColor Yellow
        Wait-KeyPress
        return
    }
    
    # ── Phase 2: Categorize entries ──
    $protectedItems = @()
    $nonEssentialItems = @()
    $unknownItems = @()
    
    foreach ($entry in $allEntries) {
        $isProtected = $false
        $isKnown = $false
        
        # Check protected whitelist
        foreach ($pattern in $protectedPatterns) {
            if ($entry.Name -like $pattern) {
                $protectedItems += [PSCustomObject]@{
                    Name     = $entry.Name
                    Value    = $entry.Value
                    Source   = $entry.Source
                    Desc     = $entry.Name
                    Category = "Protected"
                }
                $isProtected = $true
                break
            }
        }
        if ($isProtected) { continue }
        
        # Check known non-essential database
        foreach ($known in $knownNonEssential) {
            if ($entry.Name -like $known.Pattern) {
                $nonEssentialItems += [PSCustomObject]@{
                    Name     = $entry.Name
                    Value    = $entry.Value
                    Source   = $entry.Source
                    Desc     = $known.Desc
                    Category = $known.Category
                }
                $isKnown = $true
                break
            }
        }
        if ($isKnown) { continue }
        
        # Unknown - not in any list
        $unknownItems += [PSCustomObject]@{
            Name     = $entry.Name
            Value    = $entry.Value
            Source   = $entry.Source
            Desc     = $entry.Name
            Category = "Unknown"
        }
    }
    
    # ── Phase 3: Display categorized results ──
    Write-Host "`nFound $($allEntries.Count) startup entries on this PC:`n" -ForegroundColor White
    
    # Protected items
    if ($protectedItems.Count -gt 0) {
        Write-Host "  PROTECTED (will NOT be touched):" -ForegroundColor Green
        foreach ($item in $protectedItems) {
            $displayName = $item.Name.PadRight(35)
            Write-Host "  [OK] $displayName (driver/system)" -ForegroundColor DarkGreen
        }
        Write-Host ""
    }
    
    # Non-essential items grouped by category
    if ($nonEssentialItems.Count -gt 0) {
        Write-Host "  NON-ESSENTIAL (can safely disable):" -ForegroundColor Yellow
        $groups = $nonEssentialItems | Group-Object -Property Category | Sort-Object Name
        foreach ($group in $groups) {
            foreach ($item in $group.Group) {
                $displayName = $item.Name.PadRight(35)
                Write-Host "  [--] $displayName $($item.Desc) [$($item.Category)]" -ForegroundColor White
            }
        }
        Write-Host ""
    }
    
    # Unknown items
    if ($unknownItems.Count -gt 0) {
        Write-Host "  UNKNOWN (not in our database):" -ForegroundColor Gray
        foreach ($item in $unknownItems) {
            $displayName = $item.Name.PadRight(35)
            $shortValue = if ($item.Value.Length -gt 55) { $item.Value.Substring(0, 52) + "..." } else { $item.Value }
            Write-Host "  [ ? ] $displayName $shortValue" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
    
    # Nothing to disable?
    if ($nonEssentialItems.Count -eq 0 -and $unknownItems.Count -eq 0) {
        Write-Log "No non-essential startup items found. Your startup is clean!" "SUCCESS"
        Wait-KeyPress
        return
    }
    
    # ── Phase 4: User choice ──
    Write-Host "  Choose action:" -ForegroundColor Yellow
    if ($nonEssentialItems.Count -gt 0) {
        Write-Host "    A = Disable ALL non-essential ($($nonEssentialItems.Count) items)" -ForegroundColor White
    }
    Write-Host "    S = Select individually (Y/N for each item)" -ForegroundColor White
    Write-Host "    N = Skip (change nothing)" -ForegroundColor White
    Write-Host "`n  Choice ($(if($nonEssentialItems.Count -gt 0){'A/S/N'}else{'S/N'})): " -ForegroundColor Yellow -NoNewline
    $action = Read-Host
    
    $disabledCount = 0
    $disabledPatterns = @()   # Track what was disabled to clean matching tasks
    
    switch ($action.ToUpper()) {
        "A" {
            if ($nonEssentialItems.Count -eq 0) {
                Write-Host "  No non-essential items to disable." -ForegroundColor Yellow
                break
            }
            
            Write-Host "`n  Disabling all non-essential startup items..." -ForegroundColor Yellow
            foreach ($item in $nonEssentialItems) {
                try {
                    Remove-ItemProperty -Path $item.Source -Name $item.Name -ErrorAction Stop
                    Write-Log "$($item.Desc) ($($item.Name)): Disabled" "SUCCESS"
                    $disabledCount++
                    $disabledPatterns += $item.Name
                }
                catch {
                    Write-Log "$($item.Name): Could not disable - $($_.Exception.Message)" "WARNING"
                    Write-Host "    Tip: This entry may be protected by Group Policy or antivirus software" -ForegroundColor Gray
                }
            }
            
            # Ask about unknowns separately
            if ($unknownItems.Count -gt 0) {
                Write-Host ""
                if (Get-ValidYN "  Also review $($unknownItems.Count) unknown item(s)?") {
                    $i = 0
                    foreach ($item in $unknownItems) {
                        $i++
                        $shortValue = if ($item.Value.Length -gt 55) { $item.Value.Substring(0, 52) + "..." } else { $item.Value }
                        Write-Host "`n  [$i/$($unknownItems.Count)] $($item.Name)" -ForegroundColor Cyan
                        Write-Host "          Path: $shortValue" -ForegroundColor Gray
                        if (Get-ValidYN "          Disable?") {
                            try {
                                Remove-ItemProperty -Path $item.Source -Name $item.Name -ErrorAction Stop
                                Write-Log "$($item.Name): Disabled" "SUCCESS"
                                $disabledCount++
                                $disabledPatterns += $item.Name
                            }
                            catch {
                                Write-Log "$($item.Name): Could not disable" "WARNING"
                            }
                        }
                        else {
                            Write-Host "          Kept." -ForegroundColor Gray
                        }
                    }
                }
            }
        }
        "S" {
            # Select individually — combine non-essential + unknown
            $selectableItems = @()
            $selectableItems += $nonEssentialItems
            $selectableItems += $unknownItems
            $total = $selectableItems.Count
            $i = 0
            
            Write-Host ""
            foreach ($item in $selectableItems) {
                $i++
                $tag = "[$($item.Category)]"
                Write-Host "  [$i/$total] $($item.Desc) ($($item.Name)) $tag" -ForegroundColor Cyan
                if ($item.Category -eq "Unknown") {
                    $shortValue = if ($item.Value.Length -gt 55) { $item.Value.Substring(0, 52) + "..." } else { $item.Value }
                    Write-Host "          Path: $shortValue" -ForegroundColor Gray
                }
                if (Get-ValidYN "          Disable?") {
                    try {
                        Remove-ItemProperty -Path $item.Source -Name $item.Name -ErrorAction Stop
                        Write-Log "$($item.Desc) ($($item.Name)): Disabled" "SUCCESS"
                        $disabledCount++
                        $disabledPatterns += $item.Name
                    }
                    catch {
                        Write-Log "$($item.Name): Could not disable - $($_.Exception.Message)" "WARNING"
                    }
                }
                else {
                    Write-Host "          Kept." -ForegroundColor Gray
                }
            }
        }
        default {
            Write-Log "Startup optimization skipped." "INFO"
            Wait-KeyPress
            return
        }
    }
    
    # ── Phase 5: Clean matching scheduled tasks ──
    Write-Log "`n[2/3] Cleaning related scheduled tasks..." "STEP"
    $taskDisabled = 0
    $disabledTaskNames = @()   # Track already-disabled tasks to avoid duplicates
    
    # Protected task patterns — NEVER disable these even if they fuzzy-match bloat
    $protectedTaskPatterns = @(
        "*Backup*", "*BackUp*",
        "*Driver*", "*Firmware*",
        "*WindowsUpdate*", "*Windows Update*", "*wuau*",
        "*Defender*", "*Security*", "*Antivirus*", "*MpSig*",
        "*SFC*", "*DISM*", "*SystemRestore*",
        "*BitLocker*", "*Encryption*",
        "*PrinterDoctor*", "*PrinterSetup*",
        "*Microsoft\\Windows\\*"   # Core Windows scheduled tasks
    )
    
    if ($disabledPatterns.Count -gt 0) {
        foreach ($pattern in $disabledPatterns) {
            # Build search terms: raw name + cleaned database pattern
            $searchTerms = @()
            $cleanName = $pattern -replace '[^a-zA-Z0-9]', ''
            if ($cleanName.Length -ge 3) { $searchTerms += $cleanName }
            
            # Also try the database pattern (strip wildcards) for better matching
            $dbMatch = $knownNonEssential | Where-Object { $pattern -like $_.Pattern } | Select-Object -First 1
            if ($dbMatch) {
                $dbClean = $dbMatch.Pattern -replace '\*', ''
                if ($dbClean.Length -ge 3 -and $dbClean -ne $cleanName) { $searchTerms += $dbClean }
            }
            
            foreach ($term in $searchTerms) {
                $matchingTasks = $activeTasks | Where-Object { $_.TaskName -like "*$term*" -and $_.TaskName -notin $disabledTaskNames -and $_.State -ne "Disabled" }
                foreach ($task in $matchingTasks) {
                    # Check if this task is protected
                    $isTaskProtected = $false
                    foreach ($ptp in $protectedTaskPatterns) {
                        if ($task.TaskName -like $ptp -or $task.TaskPath -like $ptp) {
                            $isTaskProtected = $true
                            break
                        }
                    }
                    if ($isTaskProtected) {
                        Write-Host "  [PROTECTED] Skipped task: $($task.TaskName)" -ForegroundColor DarkGreen
                        continue
                    }
                    
                    try {
                        Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop | Out-Null
                        Write-Log "Disabled task: $($task.TaskName)" "SUCCESS"
                        $taskDisabled++
                        $disabledTaskNames += $task.TaskName
                    }
                    catch {
                        Write-Log "Could not disable task: $($task.TaskName)" "WARNING"
                    }
                }
            }
        }
    }
    
    if ($taskDisabled -gt 0) {
        Write-Log "Disabled $taskDisabled related scheduled tasks" "SUCCESS"
    }
    else {
        Write-Host "  No related scheduled tasks found." -ForegroundColor Gray
    }
    
    # ── Summary ──
    Write-Log "`n[3/3] Summary" "STEP"
    Write-Host "`n  Startup entries disabled: $disabledCount" -ForegroundColor Green
    Write-Host "  Scheduled tasks disabled: $taskDisabled" -ForegroundColor Green
    Write-Host "  Protected items kept: $($protectedItems.Count)" -ForegroundColor DarkGreen
    
    Wait-KeyPress
}

# ============================================
# 8. OPTIMIZE RAM & PERFORMANCE
# ============================================
function Optimize-RAM {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "OPTIMIZE RAM & PERFORMANCE" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Before stats
    $osBefore = Get-CimInstance Win32_OperatingSystem
    $ramBefore = [math]::Round(($osBefore.TotalVisibleMemorySize - $osBefore.FreePhysicalMemory) / 1MB, 2)
    
    # Visual Effects
    Write-Log "[1/6] Optimizing visual effects..." "STEP"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "VisualFXSetting" -Value 3 -ErrorAction SilentlyContinue
    
    # Keep font smoothing for readability
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 2 -ErrorAction SilentlyContinue
    
    # Disable animations
    $animSettings = @(
        @{Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "TaskbarAnimations"; Value = 0 },
        @{Path = "HKCU:\Control Panel\Desktop\WindowMetrics"; Name = "MinAnimate"; Value = "0" },
        @{Path = "HKCU:\Control Panel\Desktop"; Name = "MenuShowDelay"; Value = "50" }
    )
    
    foreach ($setting in $animSettings) {
        if (!(Test-Path $setting.Path)) { New-Item -Path $setting.Path -Force | Out-Null }
        Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -ErrorAction SilentlyContinue
    }
    
    # Disable transparency
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -ErrorAction SilentlyContinue
    Write-Log "Visual effects optimized" "SUCCESS"
    
    # Power Plan
    Write-Log "`n[2/6] Optimizing Power Plan..." "STEP"
    try {
        # Try to activate High Performance
        $highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        powercfg /setactive $highPerfGuid 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            # If High Performance doesn't exist, create Ultimate Performance
            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Ultimate Performance plan created!" "SUCCESS"
            }
            else {
                Write-Log "Using current power plan" "WARNING"
            }
        }
        else {
            Write-Log "High Performance plan activated" "SUCCESS"
        }
    }
    catch {
        Write-Log "Power plan optimization skipped: $($_.Exception.Message)" "WARNING"
        Write-Host "    Tip: Your device may use a manufacturer-locked power plan (common on laptops)" -ForegroundColor Gray
        Write-Host "    Fix: Check Settings > System > Power & Battery for available plans" -ForegroundColor Gray
    }
    
    # Disable Game Mode & Game Bar
    Write-Log "`n[3/6] Disabling Game Mode & Game Bar..." "STEP"
    $gameSettings = @{
        "HKCU:\Software\Microsoft\GameBar" = @{
            "AutoGameModeEnabled" = 0
            "AllowAutoGameMode"   = 0
            "ShowStartupPanel"    = 0
        }
        "HKCU:\System\GameConfigStore"     = @{
            "GameDVR_Enabled" = 0
        }
    }
    
    foreach ($path in $gameSettings.Keys) {
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        foreach ($setting in $gameSettings[$path].GetEnumerator()) {
            Set-ItemProperty -Path $path -Name $setting.Key -Value $setting.Value -ErrorAction SilentlyContinue
        }
    }
    Write-Log "Game Mode & Game DVR disabled" "SUCCESS"
    
    # Disable Cortana
    Write-Log "`n[4/6] Disabling Cortana..." "STEP"
    $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (!(Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force | Out-Null }
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
    Write-Log "Cortana disabled" "SUCCESS"
    
    # Optimize NTFS
    Write-Log "`n[5/6] Optimizing NTFS settings..." "STEP"
    fsutil behavior set DisableLastAccess 1 2>$null | Out-Null
    fsutil behavior set Disable8dot3 1 2>$null | Out-Null
    Write-Log "NTFS optimized (disabled last access timestamps & 8.3 names)" "SUCCESS"
    
    # Trim working sets system-wide (real RAM optimization)
    Write-Log "`n[6/6] Trimming process working sets (freeing idle RAM)..." "STEP"
    try {
        # Load Windows API for EmptyWorkingSet — this is what real RAM optimizers use
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        public class MemoryOptimizer {
            [DllImport("psapi.dll", SetLastError = true)]
            public static extern bool EmptyWorkingSet(IntPtr hProcess);
        }
"@ -ErrorAction SilentlyContinue
        
        $trimmedCount = 0
        $trimmedMB = 0
        $skippedCount = 0
        
        # Critical processes to NEVER trim (defined in $Config at top of script)
        $protectedProcesses = $Config.ProtectedProcesses
        
        $processes = Get-Process | Where-Object { $_.WorkingSet64 -gt ($Config.RamTrimThresholdMB * 1MB) -and $_.Id -ne $PID }
        
        foreach ($proc in $processes) {
            # Skip protected system processes
            if ($proc.ProcessName -in $protectedProcesses) {
                $skippedCount++
                continue
            }
            
            try {
                $beforeWS = $proc.WorkingSet64
                [MemoryOptimizer]::EmptyWorkingSet($proc.Handle) | Out-Null
                $proc.Refresh()
                $freed = $beforeWS - $proc.WorkingSet64
                if ($freed -gt 0) {
                    $trimmedMB += [math]::Round($freed / 1MB, 1)
                    $trimmedCount++
                }
            }
            catch {
                # Access denied for protected/system processes — expected
            }
        }
        
        # Also collect our own .NET garbage
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()
        
        Write-Log "Trimmed $trimmedCount processes, freed ~${trimmedMB} MB of idle RAM" "SUCCESS"
    }
    catch {
        Write-Log "Working set trim failed: $($_.Exception.Message)" "WARNING"
        # Fallback to basic GC
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Write-Log "Basic memory cleanup completed" "SUCCESS"
    }
    
    # After stats
    Start-Sleep -Seconds 2
    $osAfter = Get-CimInstance Win32_OperatingSystem
    $ramAfter = [math]::Round(($osAfter.TotalVisibleMemorySize - $osAfter.FreePhysicalMemory) / 1MB, 2)
    $ramSaved = $ramBefore - $ramAfter
    
    Write-Host "`n  RAM Before: $ramBefore GB" -ForegroundColor Gray
    Write-Host "  RAM After: $ramAfter GB" -ForegroundColor Gray
    Write-Host "  RAM Freed: $ramSaved GB" -ForegroundColor $(if ($ramSaved -gt 0) { "Green" }else { "Yellow" })
    
    Write-Log "`nRAM & Performance fully optimized!" "SUCCESS"
    Wait-KeyPress
}

# ============================================
# 9. OPTIMIZE WINDOWS SERVICES
# ============================================
function Optimize-Services {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "OPTIMIZE WINDOWS SERVICES" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Auto-detect boot drive type (SSD vs HDD) with multiple fallbacks
    $bootDiskType = "Unknown"
    try {
        $bootPartition = Get-Partition -DriveLetter C -ErrorAction SilentlyContinue
        if ($bootPartition) {
            $bootDisk = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DeviceId -eq "$($bootPartition.DiskNumber)" }
            if ($bootDisk) {
                $bootDiskType = $bootDisk.MediaType
                
                # Fallback 1: If MediaType is Unspecified, check BusType (NVMe = always SSD)
                if ($bootDiskType -eq "Unspecified" -or [string]::IsNullOrEmpty($bootDiskType)) {
                    if ($bootDisk.BusType -eq "NVMe") {
                        $bootDiskType = "SSD"
                    }
                }
                
                # Fallback 2: Check model name for SSD/NVMe keywords
                if ($bootDiskType -eq "Unspecified" -or [string]::IsNullOrEmpty($bootDiskType)) {
                    $modelName = $bootDisk.FriendlyName + " " + $bootDisk.Model
                    if ($modelName -match "SSD|NVMe|Solid State|M\.2") {
                        $bootDiskType = "SSD"
                    }
                    elseif ($modelName -match "HDD|Hard Disk|Seagate Barracuda|WD Blue|Toshiba DT|HGST") {
                        $bootDiskType = "HDD"
                    }
                }
                
                # Fallback 3: Check spin speed (0 RPM = SSD, >0 = HDD)
                if ($bootDiskType -eq "Unspecified" -or [string]::IsNullOrEmpty($bootDiskType)) {
                    if ($bootDisk.SpindleSpeed -eq 0) {
                        $bootDiskType = "SSD"
                    }
                    elseif ($bootDisk.SpindleSpeed -gt 0) {
                        $bootDiskType = "HDD"
                    }
                }
            }
        }
    }
    catch {}
    
    # Services to disable (safe list)
    $servicesToDisable = @(
        @{Name = "DiagTrack"; Desc = "Connected User Experiences & Telemetry" },
        @{Name = "dmwappushservice"; Desc = "WAP Push Message Service" },
        @{Name = "MapsBroker"; Desc = "Downloaded Maps Manager" },
        @{Name = "lfsvc"; Desc = "Geolocation Service" },
        @{Name = "RetailDemo"; Desc = "Retail Demo Service" },
        @{Name = "WMPNetworkSvc"; Desc = "Windows Media Player Sharing" },
        @{Name = "wisvc"; Desc = "Windows Insider Service" }
    )
    
    # Only disable SysMain (Superfetch) on HDDs -- it improves performance on SSDs
    if ($bootDiskType -eq "HDD") {
        $servicesToDisable += @{Name = "SysMain"; Desc = "Superfetch (HDD detected)" }
        Write-Host "  Boot drive: HDD detected -- SysMain will be disabled" -ForegroundColor Yellow
    }
    else {
        Write-Host "  Boot drive: $bootDiskType detected -- SysMain kept enabled (beneficial on SSDs)" -ForegroundColor Green
    }
    
    # Services to set to Manual (with smart detection)
    $servicesToManual = @(
        @{Name = "WSearch"; Desc = "Windows Search" }
    )
    
    # Detect printers -- only set Spooler to Manual if NO printers are connected
    $hasPrinters = $false
    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue | Where-Object { $_.Name -notlike "Microsoft*" -and $_.Name -notlike "Fax*" -and $_.Name -notlike "OneNote*" }
        if ($printers -and $printers.Count -gt 0) { $hasPrinters = $true }
    }
    catch {}
    
    if ($hasPrinters) {
        Write-Host "  Printers detected -- Print Spooler kept running" -ForegroundColor Green
    }
    else {
        $servicesToManual += @{Name = "Spooler"; Desc = "Print Spooler (no printers detected)" }
    }
    
    # Detect biometric devices -- only set WbioSrvc to Manual if NO biometric hardware
    $hasBiometric = $false
    try {
        $bio = Get-PnpDevice -Class "Biometric" -Status "OK" -ErrorAction SilentlyContinue
        if ($bio) { $hasBiometric = $true }
    }
    catch {}
    
    if ($hasBiometric) {
        Write-Host "  Biometric device detected -- Windows Biometric kept running" -ForegroundColor Green
    }
    else {
        $servicesToManual += @{Name = "WbioSrvc"; Desc = "Windows Biometric (no reader detected)" }
    }
    
    $servicesToManual += @{Name = "TabletInputService"; Desc = "Touch Keyboard" }
    $servicesToManual += @{Name = "Fax"; Desc = "Fax Service" }
    
    # Filter out services that are already in the target state
    $actualDisable = @()
    $alreadyDisabled = 0
    foreach ($svc in $servicesToDisable) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if (-not $service) { continue }  # Service doesn't exist on this edition -- skip silently
        if ($service.StartType -eq "Disabled") {
            $alreadyDisabled++
        }
        else {
            $actualDisable += @{Name = $svc.Name; Desc = $svc.Desc; Service = $service }
        }
    }
    
    $actualManual = @()
    $alreadyManual = 0
    foreach ($svc in $servicesToManual) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if (-not $service) { continue }  # Service doesn't exist -- skip silently
        if ($service.StartType -eq "Manual" -or $service.StartType -eq "Disabled") {
            $alreadyManual++
        }
        else {
            $actualManual += @{Name = $svc.Name; Desc = $svc.Desc; Service = $service }
        }
    }
    
    # Show summary
    if ($alreadyDisabled -gt 0 -or $alreadyManual -gt 0) {
        Write-Host "`n  Already optimized: $alreadyDisabled disabled, $alreadyManual manual (skipped)" -ForegroundColor DarkGreen
    }
    
    if ($actualDisable.Count -eq 0 -and $actualManual.Count -eq 0) {
        Write-Log "All services are already optimized! Nothing to change." "SUCCESS"
        Wait-KeyPress
        return
    }
    
    # Show what will be changed
    if ($actualDisable.Count -gt 0) {
        Write-Host "`nWill be DISABLED:" -ForegroundColor Yellow
        foreach ($svc in $actualDisable) {
            Write-Host "  - $($svc.Desc) ($($svc.Name)) [Currently: $($svc.Service.Status) / $($svc.Service.StartType)]" -ForegroundColor White
        }
    }
    if ($actualManual.Count -gt 0) {
        Write-Host "`nWill be set to MANUAL:" -ForegroundColor Yellow
        foreach ($svc in $actualManual) {
            Write-Host "  - $($svc.Desc) ($($svc.Name)) [Currently: $($svc.Service.StartType)]" -ForegroundColor White
        }
    }
    
    $optimizedCount = 0
    
    # Disable services
    if ($actualDisable.Count -gt 0) {
        Write-Host "`nDisabling services:" -ForegroundColor Yellow
        foreach ($svc in $actualDisable) {
            try {
                $service = Get-Service -Name $svc.Name -ErrorAction Stop
                if ($service.Status -eq "Running") {
                    Stop-Service $svc.Name -Force -ErrorAction Stop
                }
                Set-Service $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Log "$($svc.Desc) ($($svc.Name)): Disabled" "SUCCESS"
                $optimizedCount++
            }
            catch {
                Write-Log "$($svc.Desc): Could not disable - $($_.Exception.Message)" "WARNING"
                Write-Host "    Tip: Service may be protected by Group Policy or in use by another program" -ForegroundColor Gray
            }
        }
    }
    
    # Set services to Manual
    if ($actualManual.Count -gt 0) {
        Write-Host "`nSetting services to Manual:" -ForegroundColor Yellow
        foreach ($svc in $actualManual) {
            try {
                Set-Service $svc.Name -StartupType Manual -ErrorAction Stop
                Write-Log "$($svc.Desc) ($($svc.Name)): Set to Manual" "SUCCESS"
                $optimizedCount++
            }
            catch {
                Write-Log "$($svc.Desc): Could not change - $($_.Exception.Message)" "WARNING"
            }
        }
    }
    
    # Optimize Windows Defender
    Write-Host "`nOptimizing Windows Defender:" -ForegroundColor Yellow
    try {
        Set-MpPreference -ScanAvgCPULoadFactor $Config.DefenderMaxCpuPercent -ErrorAction SilentlyContinue
        Set-MpPreference -EnableLowCpuPriority $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue  # Keep real-time ON for safety
        Set-MpPreference -ScanScheduleQuickScanTime 12:00:00 -ErrorAction SilentlyContinue  # Scan at noon
        Write-Log "Defender optimized (low CPU priority, scan at noon)" "SUCCESS"
        $optimizedCount++
    }
    catch {
        Write-Log "Defender optimization partially failed" "WARNING"
    }
    
    Write-Log "`nOptimized $optimizedCount services! ($alreadyDisabled were already optimized)" "SUCCESS"
    Wait-KeyPress
}

# ============================================
# 10. FIX NETWORK ISSUES
# ============================================
function Repair-Network {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "FIX NETWORK ISSUES" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Before speed test
    Write-Host "Testing current connection..." -ForegroundColor Gray
    $beforeLatency = $null
    try {
        $beforePing = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
        $latencyProp = if ($beforePing[0].PSObject.Properties['Latency']) { 'Latency' } else { 'ResponseTime' }
        $beforeLatency = [math]::Round(($beforePing | Measure-Object -Property $latencyProp -Average).Average, 2)
        Write-Host "  Current latency: ${beforeLatency}ms" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Cannot reach internet" -ForegroundColor Red
    }
    
    # Check for VPN/Virtual adapters (Safety Check)
    $hasVpnAdapters = $false
    $vpnPatterns = $Config.VpnAdapterPatterns
    $allAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    foreach ($adapter in $allAdapters) {
        foreach ($p in $vpnPatterns) {
            if ($adapter.Name -like $p -or $adapter.InterfaceDescription -like $p) {
                $hasVpnAdapters = $true
                Write-Host "  Detected active VPN/Virtual adapter: $($adapter.Name)" -ForegroundColor Yellow
                break
            }
        }
    }
    
    $skipResets = $false
    if ($hasVpnAdapters) {
        Write-Host "`nWARNING: Resetting network stack (Winsock/IP) may break VPNs or VMs." -ForegroundColor Red
        Write-Host "Do you want to SKIP destructive resets and only run safe optimizations? (Recommended: Y)" -ForegroundColor Yellow
        if (Get-ValidYN "Skip resets?") {
            $skipResets = $true
            Write-Log "Skipping destructive network resets (User choice: VPN protection)" "INFO"
        }
    }
    
    Write-Log "`n[1/7] Flushing DNS cache..." "STEP"
    ipconfig /flushdns 2>$null | Out-Null
    Write-Log "DNS cache flushed" "SUCCESS"
    
    if (-not $skipResets) {
        Write-Log "`n[2/7] Resetting TCP/IP stack..." "STEP"
        netsh int ip reset 2>$null | Out-Null
        netsh int tcp reset 2>$null | Out-Null
        Write-Log "TCP/IP stack reset" "SUCCESS"
        
        Write-Log "`n[3/7] Resetting Winsock catalog..." "STEP"
        netsh winsock reset 2>$null | Out-Null
        Write-Log "Winsock catalog reset" "SUCCESS"
        
        Write-Log "`n[4/7] Resetting firewall rules..." "STEP"
        if (Get-ValidYN "  Are you in an organization or do you have custom firewall rules?") {
            Write-Log "Skipped firewall reset (custom rules preserved)" "WARNING"
        }
        else {
            netsh advfirewall reset 2>$null | Out-Null
            Write-Log "Firewall rules reset to default" "SUCCESS"
        }
    }
    else {
        Write-Log "`n[2/7] Skipped TCP/IP reset (Safe Mode)" "INFO"
        Write-Log "[3/7] Skipped Winsock reset (Safe Mode)" "INFO"
        Write-Log "[4/7] Skipped Firewall reset (Safe Mode)" "INFO"
    }
    
    Write-Log "`n[5/7] Renewing IP address..." "STEP"
    ipconfig /release 2>$null | Out-Null
    Start-Sleep -Seconds 3
    ipconfig /renew 2>$null | Out-Null
    Write-Log "IP address renewed" "SUCCESS"
    
    Write-Log "`n[6/7] Optimizing TCP settings..." "STEP"
    # Enable TCP auto-tuning
    netsh int tcp set global autotuninglevel=normal 2>$null | Out-Null
    # Enable Direct Cache Access
    netsh int tcp set global dca=enabled 2>$null | Out-Null
    # Enable Receive-Side Scaling
    netsh int tcp set global rss=enabled 2>$null | Out-Null
    # Optimize congestion control
    netsh int tcp set global congestionprovider=ctcp 2>$null | Out-Null
    Write-Log "TCP settings optimized" "SUCCESS"
    
    # DNS Configuration with PRE-CHECK
    Write-Log "`n[7/7] Configuring DNS..." "STEP"
    
    # SHOW CURRENT SETTINGS (New Feature)
    Write-Host "`n  Current Network Configuration:" -ForegroundColor Yellow
    $currAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    foreach ($adapter in $currAdapters) {
        $ip = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $dns = Get-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $gateway = Get-NetRoute -InterfaceIndex $adapter.ifIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
        Write-Host "  Adapter: $($adapter.Name)" -ForegroundColor White
        Write-Host "    IP Address: $($ip.IPAddress)" -ForegroundColor Gray
        Write-Host "    Gateway:    $($gateway.NextHop)" -ForegroundColor Gray
        Write-Host "    DNS Servers: $($dns.ServerAddresses -join ', ')" -ForegroundColor Cyan
    }
    
    $sysInfo = Get-CimInstance Win32_ComputerSystem
    
    if ($sysInfo.PartOfDomain) {
        Write-Log "Domain-joined PC detected. Skipping DNS change to preserve network policies." "WARNING"
    }
    else {
        Write-Host "`n  Choose DNS Provider:" -ForegroundColor Yellow
        Write-Host "  1. Google DNS (8.8.8.8) - Fast & reliable" -ForegroundColor White
        Write-Host "  2. Cloudflare DNS (1.1.1.1) - Fastest & private" -ForegroundColor White
        Write-Host "  3. Quad9 DNS (9.9.9.9) - Security focused" -ForegroundColor White
        Write-Host "  4. Keep current DNS" -ForegroundColor White
        Write-Host "  Choice (1-4): " -ForegroundColor Yellow -NoNewline
        $dnsChoice = Read-Host
        
        $primaryDNS = $null
        $secondaryDNS = $null
        
        switch ($dnsChoice) {
            "1" { $primaryDNS = $Config.DnsProviders.Google[0]; $secondaryDNS = $Config.DnsProviders.Google[1] }
            "2" { $primaryDNS = $Config.DnsProviders.Cloudflare[0]; $secondaryDNS = $Config.DnsProviders.Cloudflare[1] }
            "3" { $primaryDNS = $Config.DnsProviders.Quad9[0]; $secondaryDNS = $Config.DnsProviders.Quad9[1] }
            default { Write-Log "Keeping current DNS" "SUCCESS" }
        }
        
        if ($primaryDNS) {
            # Skip VPN, virtual, and loopback adapters to avoid breaking connections
            $skipPatterns = $Config.VpnAdapterPatterns
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            foreach ($adapter in $adapters) {
                $skipThis = $false
                foreach ($sp in $skipPatterns) {
                    if ($adapter.Name -like $sp -or $adapter.InterfaceDescription -like $sp) {
                        $skipThis = $true
                        break
                    }
                }
                if ($skipThis) {
                    Write-Host "    Skipped: $($adapter.Name) (VPN/Virtual adapter)" -ForegroundColor DarkYellow
                    continue
                }
                Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ($primaryDNS, $secondaryDNS) -ErrorAction SilentlyContinue
                Write-Host "    Applied: $($adapter.Name)" -ForegroundColor Green
            }
            Write-Log "DNS set to $primaryDNS / $secondaryDNS (VPN/virtual adapters skipped)" "SUCCESS"
        }
    }
    
    # After speed test
    Start-Sleep -Seconds 3
    Write-Host "`nTesting connection after fixes..." -ForegroundColor Gray
    try {
        $afterPing = Test-Connection -ComputerName 8.8.8.8 -Count 1 -ErrorAction Stop
        $latencyProp = if ($afterPing[0].PSObject.Properties['Latency']) { 'Latency' } else { 'ResponseTime' }
        $afterLatency = [math]::Round(($afterPing | Measure-Object -Property $latencyProp -Average).Average, 2)
        Write-Host "  New latency: ${afterLatency}ms" -ForegroundColor Gray
        
        if ($beforeLatency) {
            $improvement = $beforeLatency - $afterLatency
            Write-Host "  Improvement: ${improvement}ms" -ForegroundColor $(if ($improvement -gt 0) { "Green" }else { "Yellow" })
        }
    }
    catch {
        Write-Host "  Connection test failed after fixes" -ForegroundColor Red
    }
    
    Write-Log "`nNetwork fixes applied!" "SUCCESS"
    Wait-KeyPress
}

# ============================================
# 11. PRIVACY & TELEMETRY SHIELD
# ============================================
function Set-PrivacyShield {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "PRIVACY & TELEMETRY SHIELD" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $changesCount = 0
    
    # Disable Telemetry
    Write-Log "[1/8] Disabling Telemetry..." "STEP"
    $telemetrySettings = @(
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry"; Value = 0 },
        @{Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; Name = "AllowTelemetry"; Value = 0 },
        @{Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "DoNotShowFeedbackNotifications"; Value = 1 }
    )
    foreach ($setting in $telemetrySettings) {
        if (!(Test-Path $setting.Path)) { New-Item -Path $setting.Path -Force | Out-Null }
        Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -ErrorAction SilentlyContinue
        $changesCount++
    }
    Write-Log "Telemetry disabled" "SUCCESS"
    
    # Disable Activity History
    Write-Log "`n[2/8] Disabling Activity History..." "STEP"
    $activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $activityPath)) { New-Item -Path $activityPath -Force | Out-Null }
    Set-ItemProperty -Path $activityPath -Name "EnableActivityFeed" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $activityPath -Name "UploadUserActivities" -Value 0 -ErrorAction SilentlyContinue
    $changesCount += 3
    Write-Log "Activity History disabled" "SUCCESS"
    
    # Disable Location Tracking
    Write-Log "`n[3/8] Disabling Location Tracking..." "STEP"
    $locationPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
    if (!(Test-Path $locationPath)) { New-Item -Path $locationPath -Force | Out-Null }
    Set-ItemProperty -Path $locationPath -Name "DisableLocation" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $locationPath -Name "DisableWindowsLocationProvider" -Value 1 -ErrorAction SilentlyContinue
    $changesCount += 2
    Write-Log "Location tracking disabled" "SUCCESS"
    
    # Disable Advertising ID
    Write-Log "`n[4/8] Disabling Advertising ID..." "STEP"
    $adPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    if (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
    Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
    $changesCount++
    Write-Log "Advertising ID disabled" "SUCCESS"
    
    # Disable Bing Search in Start Menu
    Write-Log "`n[5/8] Disabling Bing Search in Start Menu..." "STEP"
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $searchPath -Name "CortanaConsent" -Value 0 -ErrorAction SilentlyContinue
    $changesCount += 2
    Write-Log "Bing Search in Start Menu disabled" "SUCCESS"
    
    # Disable Cloud Content & Suggestions
    Write-Log "`n[6/8] Disabling Cloud Content & Suggestions..." "STEP"
    $cloudPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (!(Test-Path $cloudPath)) { New-Item -Path $cloudPath -Force | Out-Null }
    Set-ItemProperty -Path $cloudPath -Name "DisableWindowsConsumerFeatures" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cloudPath -Name "DisableSoftLanding" -Value 1 -ErrorAction SilentlyContinue
    
    # Disable suggestions in Settings
    $contentDelivery = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $cdSettings = @(
        "SubscribedContent-338389Enabled",   # Suggested content in Settings
        "SubscribedContent-353694Enabled",    # Suggested content in Settings
        "SubscribedContent-353696Enabled",    # Suggested content in Settings
        "SubscribedContent-310093Enabled",    # Tips/tricks
        "SystemPaneSuggestionsEnabled",       # Start menu suggestions
        "SilentInstalledAppsEnabled",         # Silently installed apps
        "SoftLandingEnabled"                  # Tips about Windows
    )
    foreach ($cd in $cdSettings) {
        Set-ItemProperty -Path $contentDelivery -Name $cd -Value 0 -ErrorAction SilentlyContinue
        $changesCount++
    }
    Write-Log "Cloud content & suggestions disabled" "SUCCESS"
    
    # Disable WiFi Sense
    Write-Log "`n[7/8] Disabling WiFi Sense..." "STEP"
    $wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    if (!(Test-Path $wifiPath)) { New-Item -Path $wifiPath -Force | Out-Null }
    Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -ErrorAction SilentlyContinue
    $changesCount++
    Write-Log "WiFi Sense disabled" "SUCCESS"
    
    # Disable Clipboard History Cloud Sync
    Write-Log "`n[8/8] Disabling Clipboard Cloud Sync..." "STEP"
    $clipPath = "HKCU:\Software\Microsoft\Clipboard"
    if (!(Test-Path $clipPath)) { New-Item -Path $clipPath -Force | Out-Null }
    Set-ItemProperty -Path $clipPath -Name "EnableClipboardHistory" -Value 1 -ErrorAction SilentlyContinue  # Keep local
    Set-ItemProperty -Path $clipPath -Name "CloudClipboardAutomaticUpload" -Value 0 -ErrorAction SilentlyContinue  # No cloud
    $changesCount += 2
    Write-Log "Clipboard cloud sync disabled" "SUCCESS"
    
    Write-Host "`n  Total privacy settings applied: $changesCount" -ForegroundColor Green
    Write-Log "Privacy Shield fully activated!" "SUCCESS"
    Wait-KeyPress
}

# ============================================
# 12. WINDOWS UPDATE MANAGER
# ============================================
function Invoke-WindowsUpdateManager {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "WINDOWS UPDATE MANAGER" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Check current update status
    Write-Log "Checking Windows Update status..." "STEP"
    
    $wuService = Get-Service wuauserv -ErrorAction SilentlyContinue
    if ($wuService) {
        Write-Host "  Windows Update Service: $($wuService.Status) / $($wuService.StartType)" -ForegroundColor White
    }
    else {
        Write-Host "  Windows Update Service: Not found" -ForegroundColor Red
    }
    
    # Show current pause status
    $regPath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    try {
        $pauseExpiry = Get-ItemPropertyValue -Path $regPath -Name "PauseUpdatesExpiryTime" -ErrorAction SilentlyContinue
        if ($pauseExpiry) {
            $expiryDate = [datetime]::Parse($pauseExpiry)
            if ($expiryDate -gt (Get-Date)) {
                Write-Host "  Update Status: PAUSED until $($expiryDate.ToString('yyyy-MM-dd'))" -ForegroundColor Yellow
            }
            else {
                Write-Host "  Update Status: Active (not paused)" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  Update Status: Active (not paused)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  Update Status: Active (not paused)" -ForegroundColor Green
    }
    
    # Show current active hours
    try {
        $activeStart = Get-ItemPropertyValue -Path $regPath -Name "ActiveHoursStart" -ErrorAction SilentlyContinue
        $activeEnd = Get-ItemPropertyValue -Path $regPath -Name "ActiveHoursEnd" -ErrorAction SilentlyContinue
        if ($null -ne $activeStart -and $null -ne $activeEnd) {
            $startAmPm = if ($activeStart -lt 12) { "$($activeStart) AM" } elseif ($activeStart -eq 12) { "12 PM" } else { "$($activeStart - 12) PM" }
            $endAmPm = if ($activeEnd -lt 12) { "$($activeEnd) AM" } elseif ($activeEnd -eq 12) { "12 PM" } else { "$($activeEnd - 12) PM" }
            Write-Host "  Active Hours: $startAmPm - $endAmPm (no restarts during these hours)" -ForegroundColor Gray
        }
    }
    catch {}
    
    # Check pending updates
    Write-Host "`n  Searching for pending updates (this may take a moment)..." -ForegroundColor Gray
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        
        if ($searchResult.Updates.Count -gt 0) {
            Write-Host "  Pending Updates ($($searchResult.Updates.Count)):" -ForegroundColor Yellow
            foreach ($update in $searchResult.Updates) {
                $size = [math]::Round($update.MaxDownloadSize / 1MB, 1)
                Write-Host "    - $($update.Title) [$size MB]" -ForegroundColor White
            }
        }
        else {
            Write-Host "  No pending updates. System is up to date!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  Could not check for updates" -ForegroundColor Gray
        Write-Host "  Tip: Windows Update service may be paused or disabled" -ForegroundColor DarkGray
        Write-Host "  Fix: Run 'services.msc' and ensure 'Windows Update' is running" -ForegroundColor DarkGray
    }
    
    # Last update time
    try {
        $lastUpdate = Get-HotFix | Sort-Object InstalledOn -Descending -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($lastUpdate -and $lastUpdate.InstalledOn) {
            Write-Host "  Last Update Installed: $($lastUpdate.InstalledOn.ToString('yyyy-MM-dd')) - $($lastUpdate.HotFixID)" -ForegroundColor Gray
        }
    }
    catch {}
    
    # Options
    Write-Host "`n  Options:" -ForegroundColor Yellow
    Write-Host "  1. Check for updates now (opens Settings)" -ForegroundColor White
    Write-Host "  2. Pause updates (choose 1-$($Config.MaxUpdatePauseDays) days)" -ForegroundColor White
    Write-Host "  3. Resume updates (unpause)" -ForegroundColor White
    Write-Host "  4. Set active hours (prevent restart during work)" -ForegroundColor White
    Write-Host "  5. Clear update cache (fix stuck updates)" -ForegroundColor White
    Write-Host "  0. Back to menu" -ForegroundColor White
    Write-Host "`n  Choice (0-5): " -ForegroundColor Yellow -NoNewline
    $updateChoice = (Read-Host).Trim()
    
    switch ($updateChoice) {
        "1" {
            Write-Log "Opening Windows Update..." "STEP"
            Start-Process "ms-settings:windowsupdate"
            Write-Log "Windows Update settings opened" "SUCCESS"
        }
        "2" {
            Write-Host "  How many days to pause updates? (1-$($Config.MaxUpdatePauseDays)): " -ForegroundColor Yellow -NoNewline
            $pauseDays = (Read-Host).Trim()
            
            # Validate input
            $pauseDaysInt = 0
            if (-not [int]::TryParse($pauseDays, [ref]$pauseDaysInt) -or $pauseDaysInt -lt 1 -or $pauseDaysInt -gt $Config.MaxUpdatePauseDays) {
                Write-Log "Invalid input. Please enter a number between 1 and $($Config.MaxUpdatePauseDays)." "WARNING"
            }
            else {
                Write-Log "Pausing updates for $pauseDaysInt days..." "STEP"
                $pauseDate = (Get-Date).AddDays($pauseDaysInt).ToString("yyyy-MM-ddTHH:mm:ssZ")
                Set-ItemProperty -Path $regPath -Name "PauseUpdatesExpiryTime" -Value $pauseDate -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $regPath -Name "PauseFeatureUpdatesStartTime" -Value (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $regPath -Name "PauseFeatureUpdatesEndTime" -Value $pauseDate -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $regPath -Name "PauseQualityUpdatesStartTime" -Value (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ") -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $regPath -Name "PauseQualityUpdatesEndTime" -Value $pauseDate -ErrorAction SilentlyContinue
                Write-Log "Updates paused until $(Get-Date (Get-Date).AddDays($pauseDaysInt) -Format 'yyyy-MM-dd')" "SUCCESS"
            }
        }
        "3" {
            Write-Log "Resuming Windows Updates..." "STEP"
            try {
                Remove-ItemProperty -Path $regPath -Name "PauseUpdatesExpiryTime" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $regPath -Name "PauseFeatureUpdatesStartTime" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $regPath -Name "PauseFeatureUpdatesEndTime" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $regPath -Name "PauseQualityUpdatesStartTime" -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path $regPath -Name "PauseQualityUpdatesEndTime" -ErrorAction SilentlyContinue
                Write-Log "Windows Updates resumed! Updates will check automatically." "SUCCESS"
            }
            catch {
                Write-Log "Could not resume updates: $($_.Exception.Message)" "WARNING"
            }
        }
        "4" {
            Write-Host "  Set your active hours (Windows won't restart during these hours)." -ForegroundColor Gray
            Write-Host "`n  Choose a preset or enter custom hours:" -ForegroundColor Yellow
            Write-Host "    1. Morning worker   (6 AM - 10 PM)" -ForegroundColor White
            Write-Host "    2. Regular worker   (8 AM - 11 PM)" -ForegroundColor White
            Write-Host "    3. Night owl        (12 PM - 4 AM)" -ForegroundColor White
            Write-Host "    4. Custom (enter your own)" -ForegroundColor White
            Write-Host "  Choice (1-4): " -ForegroundColor Yellow -NoNewline
            $hoursChoice = (Read-Host).Trim()
            
            $startHour = $null
            $endHour = $null
            
            switch ($hoursChoice) {
                "1" { $startHour = 6; $endHour = 22 }
                "2" { $startHour = 8; $endHour = 23 }
                "3" { $startHour = 12; $endHour = 4 }
                "4" {
                    Write-Host "  Start hour (0-23, e.g. 8 for 8 AM): " -ForegroundColor Yellow -NoNewline
                    $startInput = (Read-Host).Trim()
                    Write-Host "  End hour (0-23, e.g. 23 for 11 PM): " -ForegroundColor Yellow -NoNewline
                    $endInput = (Read-Host).Trim()
                    
                    $s = 0; $e = 0
                    if ([int]::TryParse($startInput, [ref]$s) -and [int]::TryParse($endInput, [ref]$e) -and $s -ge 0 -and $s -le 23 -and $e -ge 0 -and $e -le 23 -and $s -ne $e) {
                        $startHour = $s
                        $endHour = $e
                    }
                    else {
                        Write-Log "Invalid hours. Enter values 0-23, start and end must be different." "WARNING"
                    }
                }
                default {
                    Write-Host "  Cancelled." -ForegroundColor Gray
                }
            }
            
            if ($null -ne $startHour -and $null -ne $endHour) {
                Set-ItemProperty -Path $regPath -Name "ActiveHoursStart" -Value $startHour -ErrorAction SilentlyContinue
                Set-ItemProperty -Path $regPath -Name "ActiveHoursEnd" -Value $endHour -ErrorAction SilentlyContinue
                $startAmPm = if ($startHour -lt 12) { "$($startHour) AM" } elseif ($startHour -eq 12) { "12 PM" } else { "$($startHour - 12) PM" }
                $endAmPm = if ($endHour -lt 12) { "$($endHour) AM" } elseif ($endHour -eq 12) { "12 PM" } else { "$($endHour - 12) PM" }
                Write-Log "Active hours set: $startAmPm - $endAmPm" "SUCCESS"
            }
        }
        "5" {
            Write-Log "Clearing Windows Update cache..." "STEP"
            Write-Host "  Stopping update services..." -ForegroundColor Gray
            Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
            Stop-Service bits -Force -ErrorAction SilentlyContinue
            Stop-Service cryptSvc -Force -ErrorAction SilentlyContinue
            
            Write-Host "  Deleting cached update files..." -ForegroundColor Gray
            Remove-Item "$env:WINDIR\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "$env:WINDIR\System32\catroot2\*" -Recurse -Force -ErrorAction SilentlyContinue
            
            Write-Host "  Restarting update services..." -ForegroundColor Gray
            Start-Service wuauserv -ErrorAction SilentlyContinue
            Start-Service bits -ErrorAction SilentlyContinue
            Start-Service cryptSvc -ErrorAction SilentlyContinue
            
            # Verify services came back
            Start-Sleep -Seconds 2
            $wuCheck = Get-Service wuauserv -ErrorAction SilentlyContinue
            if ($wuCheck -and $wuCheck.Status -eq "Running") {
                Write-Log "Update cache cleared and services restarted successfully." "SUCCESS"
            }
            else {
                Write-Log "Update cache cleared but Windows Update service may need a restart to recover." "WARNING"
                Write-Host "  Tip: If updates are still stuck, restart your PC and try again." -ForegroundColor Gray
            }
        }
        "0" {
            return
        }
        default {
            Write-Host "  Invalid choice." -ForegroundColor Red
        }
    }
    
    Wait-KeyPress
}

# ============================================
# 13. DEEP DISK CLEAN
# ============================================
function Invoke-DiskCleanup {
    param([switch]$Auto)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "DEEP DISK CLEANUP" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $beforeCleanup = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    $beforeFreeGB = [math]::Round($beforeCleanup.SizeRemaining / 1GB, 2)
    Write-Host "  Current free space on C: $beforeFreeGB GB`n" -ForegroundColor Gray
    
    if ($Auto) {
        # Auto mode: skip prompts, skip Recycle Bin (safe default)
        $cleanRecycleBin = $false
    }
    else {
        # Interactive mode: two upfront questions, zero prompts after
        if (-not (Get-ValidYN "  Start cleanup?")) {
            Write-Log "Disk cleanup cancelled by user" "INFO"
            Wait-KeyPress
            return
        }
        $cleanRecycleBin = Get-ValidYN "  Also empty Recycle Bin?"
        Write-Host ""
    }
    
    # Helper: get folder size in MB (fast, pre-deletion measurement)
    function Get-FolderSizeMB {
        param([string]$Path)
        if (-not (Test-Path $Path)) { return 0 }
        $bytes = (Get-ChildItem -Path $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        if ($bytes) { return [math]::Round($bytes / 1MB, 1) }
        return 0
    }
    
    # Helper: format MB nicely
    function Format-Size {
        param([double]$MB)
        if ($MB -ge 1024) { return "$([math]::Round($MB / 1024, 1)) GB" }
        return "$([math]::Round($MB)) MB"
    }
    
    $totalCleaned = 0
    
    # ── Step 1: Temp files, thumbnails, icon cache ──
    Write-Log "[1/5] Clearing temp files & cache..." "STEP"
    
    # Deduplicate temp paths (TEMP and LOCALAPPDATA\Temp are often identical)
    $tempFolders = @("$env:TEMP", "$env:WINDIR\Temp", "$env:LOCALAPPDATA\Temp")
    $resolvedTempPaths = @()
    foreach ($folder in $tempFolders) {
        if (Test-Path $folder) {
            $fullPath = (Resolve-Path $folder -ErrorAction SilentlyContinue).Path
            if ($fullPath -and $fullPath -notin $resolvedTempPaths) {
                $resolvedTempPaths += $fullPath
            }
        }
    }
    
    # Measure size before deleting
    $tempSizeMB = 0
    foreach ($folder in $resolvedTempPaths) {
        $tempSizeMB += Get-FolderSizeMB $folder
    }
    
    # Delete everything — single call, no file-by-file, no prompts
    foreach ($folder in $resolvedTempPaths) {
        Get-ChildItem -Path $folder -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }
    
    # Thumbnail + icon cache
    $thumbPath = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
    if (Test-Path $thumbPath) {
        $thumbFiles = Get-ChildItem -Path $thumbPath -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "thumbcache_*" -or $_.Name -like "iconcache_*" }
        if ($thumbFiles) {
            $tempSizeMB += [math]::Round(($thumbFiles | Measure-Object -Property Length -Sum).Sum / 1MB, 1)
            $thumbFiles | Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }
    
    $totalCleaned += $tempSizeMB
    Write-Log "Temp files & cache: $(Format-Size $tempSizeMB) cleaned" "SUCCESS"
    
    # ── Step 2: Browser caches ──
    Write-Log "`n[2/5] Clearing browser caches..." "STEP"
    
    # Browser definitions: name, paths
    $browserDefs = @(
        @{ Name = "Edge"; Paths = @(
                "$env:LocalAppData\Microsoft\Edge\User Data\*\Cache",
                "$env:LocalAppData\Microsoft\Edge\User Data\*\Cache_Data",
                "$env:LocalAppData\Microsoft\Edge\User Data\*\Code Cache",
                "$env:LocalAppData\Microsoft\Edge\User Data\*\GPUCache",
                "$env:LocalAppData\Microsoft\Edge\User Data\*\Service Worker\CacheStorage"
            )
        },
        @{ Name = "Chrome"; Paths = @(
                "$env:LocalAppData\Google\Chrome\User Data\*\Cache",
                "$env:LocalAppData\Google\Chrome\User Data\*\Cache_Data",
                "$env:LocalAppData\Google\Chrome\User Data\*\Code Cache",
                "$env:LocalAppData\Google\Chrome\User Data\*\GPUCache",
                "$env:LocalAppData\Google\Chrome\User Data\*\Service Worker\CacheStorage"
            )
        },
        @{ Name = "Brave"; Paths = @(
                "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\*\Cache",
                "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\*\Cache_Data",
                "$env:LocalAppData\BraveSoftware\Brave-Browser\User Data\*\Code Cache"
            )
        },
        @{ Name = "Vivaldi"; Paths = @(
                "$env:LocalAppData\Vivaldi\User Data\*\Cache",
                "$env:LocalAppData\Vivaldi\User Data\*\Cache_Data",
                "$env:LocalAppData\Vivaldi\User Data\*\Code Cache"
            )
        },
        @{ Name = "Arc"; Paths = @(
                "$env:LocalAppData\Arc\User Data\*\Cache",
                "$env:LocalAppData\Arc\User Data\*\Cache_Data",
                "$env:LocalAppData\Arc\User Data\*\Code Cache"
            )
        },
        @{ Name = "Opera"; Paths = @(
                "$env:LocalAppData\Opera Software\Opera Stable\Cache",
                "$env:LocalAppData\Opera Software\Opera Stable\Cache_Data",
                "$env:AppData\Opera Software\Opera Stable\Cache"
            )
        },
        @{ Name = "Floorp"; Paths = @(
                "$env:LocalAppData\Floorp\User Data\*\Cache",
                "$env:LocalAppData\Floorp\User Data\*\Cache_Data"
            )
        },
        @{ Name = "Comet"; Paths = @(
                "$env:LocalAppData\Comet\User Data\*\Cache",
                "$env:LocalAppData\Comet\User Data\*\Cache_Data"
            )
        },
        @{ Name = "Firefox"; Paths = @(
                "$env:LocalAppData\Mozilla\Firefox\Profiles\*.default*\cache2"
            )
        },
        @{ Name = "Waterfox"; Paths = @(
                "$env:LocalAppData\Waterfox\Profiles\*.default*\cache2"
            )
        },
        @{ Name = "Zen"; Paths = @(
                "$env:LocalAppData\Zen\Profiles\*.default*\cache2"
            )
        },
        @{ Name = "Tor"; Paths = @(
                "$env:LocalAppData\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\cache2"
            )
        }
    )
    
    $browserTotalMB = 0
    $browserResults = @()
    
    foreach ($browser in $browserDefs) {
        $browserSizeMB = 0
        $found = $false
        
        foreach ($cachePath in $browser.Paths) {
            $resolvedPaths = Resolve-Path $cachePath -ErrorAction SilentlyContinue
            foreach ($resolved in $resolvedPaths) {
                if (Test-Path $resolved) {
                    $found = $true
                    $browserSizeMB += Get-FolderSizeMB $resolved.Path
                    Remove-Item -Path "$($resolved.Path)\*" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                }
            }
        }
        
        if ($found -and $browserSizeMB -gt 0) {
            $browserResults += "    $($browser.Name): $(Format-Size $browserSizeMB)"
            $browserTotalMB += $browserSizeMB
        }
    }
    
    if ($browserResults.Count -gt 0) {
        foreach ($line in $browserResults) {
            Write-Host $line -ForegroundColor Gray
        }
    }
    $totalCleaned += $browserTotalMB
    Write-Log "Browser caches: $(Format-Size $browserTotalMB) cleaned" "SUCCESS"
    
    # ── Step 3: Windows Update cache ──
    Write-Log "`n[3/5] Clearing Windows Update cache..." "STEP"
    
    # Remember service states to restore properly
    $wuBefore = (Get-Service wuauserv -ErrorAction SilentlyContinue).Status
    $bitsBefore = (Get-Service bits -ErrorAction SilentlyContinue).Status
    
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue 2>$null
    Stop-Service bits -Force -ErrorAction SilentlyContinue 2>$null
    Start-Sleep -Seconds 1
    
    $wuPaths = @(
        "$env:WINDIR\SoftwareDistribution\Download",
        "$env:WINDIR\SoftwareDistribution\DataStore"
    )
    $wuSizeMB = 0
    foreach ($path in $wuPaths) {
        $wuSizeMB += Get-FolderSizeMB $path
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    
    # Restore services to previous state
    if ($wuBefore -eq "Running") {
        Start-Service wuauserv -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    if ($bitsBefore -eq "Running") {
        Start-Service bits -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    
    $totalCleaned += $wuSizeMB
    Write-Log "Windows Update cache: $(Format-Size $wuSizeMB) cleaned" "SUCCESS"
    
    # ── Step 4: Old logs, crash dumps, and optional Recycle Bin ──
    Write-Log "`n[4/5] Clearing old logs & crash dumps..." "STEP"
    
    $logFolders = @(
        "$env:WINDIR\Logs\CBS",
        "$env:WINDIR\Panther",
        "$env:LOCALAPPDATA\CrashDumps",
        "$env:WINDIR\Minidump"
    )
    $logSizeMB = 0
    foreach ($logFolder in $logFolders) {
        if (Test-Path $logFolder) {
            $oldFiles = Get-ChildItem -Path $logFolder -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays( - $($Config.LogCleanupDays)) }
            if ($oldFiles) {
                $logSizeMB += [math]::Round(($oldFiles | Where-Object { -not $_.PSIsContainer } |
                        Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB, 1)
                $oldFiles | Remove-Item -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
    }
    
    $totalCleaned += $logSizeMB
    Write-Log "Old logs (>$($Config.LogCleanupDays) days): $(Format-Size $logSizeMB) cleaned" "SUCCESS"
    
    # Recycle Bin (if user opted in)
    if ($cleanRecycleBin) {
        try {
            Clear-RecycleBin -Force -ErrorAction Stop
            Write-Log "Recycle Bin emptied" "SUCCESS"
        }
        catch {
            Write-Log "Recycle Bin: already empty or could not clear" "INFO"
        }
    }
    else {
        Write-Host "    Recycle Bin: Skipped (user choice)" -ForegroundColor Gray
    }
    
    # ── Step 5: Drive optimization (SSD TRIM / HDD Defrag) ──
    Write-Log "`n[5/5] Optimizing drives..." "STEP"
    $fixedVolumes = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq "Fixed" }
    foreach ($vol in $fixedVolumes) {
        try {
            $diskType = "Unknown"
            $partition = Get-Partition -DriveLetter $vol.DriveLetter -ErrorAction SilentlyContinue
            if ($partition) {
                $physDisk = Get-PhysicalDisk -ErrorAction SilentlyContinue |
                Where-Object { $_.DeviceId -eq "$($partition.DiskNumber)" }
                if ($physDisk) { $diskType = $physDisk.MediaType }
            }
            
            if ($diskType -eq "SSD") {
                Optimize-Volume -DriveLetter $vol.DriveLetter -ReTrim -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Drive $($vol.DriveLetter): SSD TRIM completed" "SUCCESS"
            }
            elseif ($diskType -eq "HDD") {
                Write-Log "Drive $($vol.DriveLetter): Running HDD Defrag (this will take time)..." "INFO"
                Optimize-Volume -DriveLetter $vol.DriveLetter -Defrag -Verbose *>&1 | ForEach-Object {
                    # If it's a progress string, print it on the same line to avoid spam
                    if ($_ -match "%\s*Complete") {
                        Write-Host "`r    $_   " -NoNewline -ForegroundColor Gray
                    }
                }
                Write-Host "" # Newline after progress finishes
                Write-Log "Drive $($vol.DriveLetter): HDD Defrag completed" "SUCCESS"
            }
            else {
                Write-Host "    Drive $($vol.DriveLetter): Skipped (type unknown -- check with Option 5)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Log "Drive $($vol.DriveLetter): Could not optimize" "WARNING"
        }
    }
    
    # ── Final Results ──
    Start-Sleep -Seconds 1
    $afterCleanup = Get-Volume -DriveLetter C -ErrorAction SilentlyContinue
    $afterFreeGB = [math]::Round($afterCleanup.SizeRemaining / 1GB, 2)
    $freedSpace = [math]::Round($afterFreeGB - $beforeFreeGB, 2)
    if ($freedSpace -lt 0) { $freedSpace = 0 }
    
    Write-Host "`n  ==========================================" -ForegroundColor Cyan
    Write-Host "  Cleaned: ~$(Format-Size $totalCleaned) of junk identified" -ForegroundColor White
    Write-Host "  Before:  $beforeFreeGB GB free" -ForegroundColor Gray
    Write-Host "  After:   $afterFreeGB GB free" -ForegroundColor Gray
    Write-Host "  Freed:   $freedSpace GB" -ForegroundColor $(if ($freedSpace -gt 0) { "Green" }else { "White" })
    Write-Host "  ==========================================" -ForegroundColor Cyan
    
    Wait-KeyPress
}

# ============================================
# 14. BLOATWARE UNINSTALLER (UWP Apps)
# ============================================
function Remove-Bloatware {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "BLOATWARE UNINSTALLER (UWP Apps)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Log "Scanning for installed UWP apps..." "STEP"
    
    # Apps to NEVER remove (essential for Windows functionality)
    $protectedApps = @(
        "*WindowsStore*", "*StorePurchaseApp*", "*DesktopAppInstaller*",
        "*WindowsTerminal*", "*WindowsNotepad*", "*Paint*",
        "*ScreenSketch*", "*SnippingTool*", "*WindowsCalculator*",
        "*Photos*", "*HEIFImageExtension*", "*VP9VideoExtensions*",
        "*WebMediaExtensions*", "*WebpImageExtension*", "*RawImageExtension*",
        "*SecHealthUI*", "*WindowsSecurity*", "*StartMenuExperienceHost*",
        "*ShellExperienceHost*", "*Windows.Search*", "*WindowsAppRuntime*",
        "*.NET*", "*VCLibs*", "*UI.Xaml*", "*AppRuntime*", "*Framework*"
    )
    
    # ── LIST 1: DEFINITE JUNK (nobody needs these pre-installed) ──
    $definiteJunk = @(
        # Junk games
        @{Pattern = "*CandyCrush*"; Desc = "Candy Crush Saga" },
        @{Pattern = "*BubbleWitch*"; Desc = "Bubble Witch Saga" },
        @{Pattern = "*MarchofEmpires*"; Desc = "March of Empires" },
        @{Pattern = "*HiddenCityMystery*"; Desc = "Hidden City" },
        @{Pattern = "*RoyalRevolt*"; Desc = "Royal Revolt" },
        @{Pattern = "*AutodeskSketchBook*"; Desc = "Autodesk SketchBook" },
        @{Pattern = "*WildTangent*"; Desc = "WildTangent Games" },
        # Bing suite
        @{Pattern = "*BingNews*"; Desc = "Bing News" },
        @{Pattern = "*BingFinance*"; Desc = "Bing Finance" },
        @{Pattern = "*BingSports*"; Desc = "Bing Sports" },
        @{Pattern = "*BingTranslator*"; Desc = "Bing Translator" },
        # Dead/useless MS apps
        @{Pattern = "*Microsoft3DViewer*"; Desc = "3D Viewer" },
        @{Pattern = "*3DBuilder*"; Desc = "3D Builder" },
        @{Pattern = "*Print3D*"; Desc = "Print 3D" },
        @{Pattern = "*MixedReality*"; Desc = "Mixed Reality Portal" },
        @{Pattern = "*OneConnect*"; Desc = "Paid Wi-Fi & Cellular" },
        @{Pattern = "*People*"; Desc = "People App" },
        @{Pattern = "*Getstarted*"; Desc = "Tips / Get Started" },
        @{Pattern = "*GetHelp*"; Desc = "Get Help" },
        @{Pattern = "*FeedbackHub*"; Desc = "Feedback Hub" },
        @{Pattern = "*Wallet*"; Desc = "Microsoft Wallet" },
        @{Pattern = "*MicrosoftOfficeHub*"; Desc = "Office Hub (Get Office)" },
        @{Pattern = "*PowerAutomateDesktop*"; Desc = "Power Automate" },
        @{Pattern = "*ZuneMusic*"; Desc = "Groove Music" },
        @{Pattern = "*ZuneVideo*"; Desc = "Movies & TV" },
        # OEM trial junk
        @{Pattern = "*McAfee*"; Desc = "McAfee Security (trial)" },
        @{Pattern = "*Norton*"; Desc = "Norton Security (trial)" },
        @{Pattern = "*ExpressVPN*"; Desc = "ExpressVPN (trial)" },
        @{Pattern = "*CyberLink*"; Desc = "CyberLink Media" }
    )
    
    # ── LIST 2: POPULAR APPS (pre-installed, but people often use them) ──
    $popularApps = @(
        @{Pattern = "*SpotifyMusic*"; Desc = "Spotify" },
        @{Pattern = "*Netflix*"; Desc = "Netflix" },
        @{Pattern = "*AmazonPrime*"; Desc = "Amazon Prime Video" },
        @{Pattern = "*WhatsApp*"; Desc = "WhatsApp" },
        @{Pattern = "*Instagram*"; Desc = "Instagram" },
        @{Pattern = "*Facebook*"; Desc = "Facebook" },
        @{Pattern = "*Twitter*"; Desc = "Twitter / X" },
        @{Pattern = "*TikTok*"; Desc = "TikTok" },
        @{Pattern = "*LinkedInforWindows*"; Desc = "LinkedIn" },
        @{Pattern = "*Disney*"; Desc = "Disney+" },
        @{Pattern = "*Clipchamp*"; Desc = "Clipchamp Video Editor" },
        @{Pattern = "*MicrosoftTeams*"; Desc = "Microsoft Teams" },
        @{Pattern = "*SkypeApp*"; Desc = "Skype" },
        @{Pattern = "*YourPhone*"; Desc = "Phone Link" },
        @{Pattern = "*Solitaire*"; Desc = "Microsoft Solitaire" },
        @{Pattern = "*MicrosoftMahjong*"; Desc = "Microsoft Mahjong" },
        @{Pattern = "*BingWeather*"; Desc = "Weather App" },
        @{Pattern = "*WindowsMaps*"; Desc = "Windows Maps" },
        @{Pattern = "*Todos*"; Desc = "Microsoft To-Do" },
        @{Pattern = "*Whiteboard*"; Desc = "Microsoft Whiteboard" },
        @{Pattern = "*Plex*"; Desc = "Plex" },
        @{Pattern = "*Dolby*"; Desc = "Dolby Access" },
        @{Pattern = "*GamingApp*"; Desc = "Xbox App" },
        @{Pattern = "*XboxApp*"; Desc = "Xbox Console Companion" },
        @{Pattern = "*Xbox.TCUI*"; Desc = "Xbox TCUI" },
        @{Pattern = "*XboxSpeechToText*"; Desc = "Xbox Speech to Text" },
        @{Pattern = "*XboxIdentityProvider*"; Desc = "Xbox Identity" },
        @{Pattern = "*XboxGameOverlay*"; Desc = "Xbox Game Overlay" },
        @{Pattern = "*XboxGamingOverlay*"; Desc = "Xbox Game Bar" }
    )
    
    # Scan installed apps
    $allApps = Get-AppxPackage -ErrorAction SilentlyContinue | Where-Object { $_.NonRemovable -eq $false }
    
    if (-not $allApps) {
        Write-Log "Could not retrieve installed apps" "WARNING"
        Wait-KeyPress
        return
    }
    
    # Match installed apps against both lists
    $junkFound = @()
    $popularFound = @()
    
    foreach ($app in $allApps) {
        # Skip protected apps
        $isProtected = $false
        foreach ($p in $protectedApps) {
            if ($app.Name -like $p) { $isProtected = $true; break }
        }
        if ($isProtected) { continue }
        
        # Check definite junk first
        $matched = $false
        foreach ($junk in $definiteJunk) {
            if ($app.Name -like $junk.Pattern) {
                $junkFound += [PSCustomObject]@{ Name = $app.Name; FullName = $app.PackageFullName; Desc = $junk.Desc }
                $matched = $true; break
            }
        }
        if ($matched) { continue }
        
        # Check popular apps
        foreach ($pop in $popularApps) {
            if ($app.Name -like $pop.Pattern) {
                $popularFound += [PSCustomObject]@{ Name = $app.Name; FullName = $app.PackageFullName; Desc = $pop.Desc }
                break
            }
        }
    }
    
    $totalFound = $junkFound.Count + $popularFound.Count
    if ($totalFound -eq 0) {
        Write-Log "No known bloatware found. Your system is clean!" "SUCCESS"
        Wait-KeyPress
        return
    }
    
    # ── Display Results ──
    if ($junkFound.Count -gt 0) {
        Write-Host "  DEFINITE JUNK ($($junkFound.Count) apps) - safe to remove:" -ForegroundColor Red
        foreach ($item in $junkFound) {
            Write-Host "    x  $($item.Desc)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    if ($popularFound.Count -gt 0) {
        Write-Host "  POPULAR APPS ($($popularFound.Count) apps) - you might actually use these:" -ForegroundColor Yellow
        foreach ($item in $popularFound) {
            Write-Host "    ?  $($item.Desc)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    # ── Action Menu ──
    Write-Host "  --- What do you want to do? ---" -ForegroundColor DarkCyan
    if ($junkFound.Count -gt 0) {
        Write-Host "    1 = Remove JUNK ONLY ($($junkFound.Count) apps), keep popular apps (Recommended)" -ForegroundColor Green
    }
    Write-Host "    2 = Remove ALL ($totalFound apps, junk + popular)" -ForegroundColor White
    if ($junkFound.Count -gt 0 -and $popularFound.Count -gt 0) {
        Write-Host "    3 = Remove junk + choose which popular apps to KEEP" -ForegroundColor White
    }
    Write-Host "    4 = Select individually (Y/N for every app)" -ForegroundColor White
    Write-Host "    0 = Cancel (remove nothing)" -ForegroundColor DarkGray
    Write-Host "  Choice: " -ForegroundColor Yellow -NoNewline
    $action = Read-Host
    
    $removedCount = 0
    
    # Helper to remove a list of apps
    function Remove-AppList {
        param([array]$AppList)
        $count = 0
        foreach ($item in $AppList) {
            try {
                Get-AppxPackage -Name $item.Name -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction Stop
                Write-Log "Removed: $($item.Desc)" "SUCCESS"
                $count++
            }
            catch {
                Write-Log "Could not remove $($item.Desc): $($_.Exception.Message)" "WARNING"
            }
        }
        return $count
    }
    
    switch ($action) {
        "1" {
            if ($junkFound.Count -gt 0) {
                Write-Host "`n  Removing definite junk...`n" -ForegroundColor Yellow
                $removedCount = Remove-AppList -AppList $junkFound
                if ($popularFound.Count -gt 0) {
                    $popularNames = ($popularFound | ForEach-Object { $_.Desc }) -join ", "
                    Write-Host "  Kept $($popularFound.Count) popular app(s): $popularNames" -ForegroundColor Gray
                }
            }
        }
        "2" {
            if (Get-ValidYN "`n  This will also remove popular apps. Are you sure?") {
                Write-Host "`n  Removing everything...`n" -ForegroundColor Yellow
                $removedCount += (Remove-AppList -AppList $junkFound)
                $removedCount += (Remove-AppList -AppList $popularFound)
            }
        }
        "3" {
            if ($junkFound.Count -gt 0 -and $popularFound.Count -gt 0) {
                # Remove all junk first
                Write-Host "`n  Removing definite junk...`n" -ForegroundColor Yellow
                $removedCount = Remove-AppList -AppList $junkFound
                
                # Ask about each popular app
                Write-Host "`n  Now choose which popular apps to KEEP:" -ForegroundColor Yellow
                Write-Host "  (Answer N to remove, Y to keep)`n" -ForegroundColor Gray
                $i = 0
                foreach ($item in $popularFound) {
                    $i++
                    if (Get-ValidYN "  [$i/$($popularFound.Count)] Keep $($item.Desc)?") {
                        Write-Host "    Kept." -ForegroundColor Green
                    }
                    else {
                        try {
                            Get-AppxPackage -Name $item.Name -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction Stop
                            Write-Log "Removed: $($item.Desc)" "SUCCESS"
                            $removedCount++
                        }
                        catch {
                            Write-Log "Could not remove $($item.Desc): $($_.Exception.Message)" "WARNING"
                        }
                    }
                }
            }
        }
        "4" {
            Write-Host ""
            $allItems = @($junkFound) + @($popularFound)
            $i = 0
            foreach ($item in $allItems) {
                $i++
                $tag = if ($item -in $junkFound) { "[Junk]" } else { "[Popular]" }
                if (Get-ValidYN ("  [$i/$totalFound] Remove $($item.Desc) " + $tag + "?")) {
                    try {
                        Get-AppxPackage -Name $item.Name -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction Stop
                        Write-Log "Removed: $($item.Desc)" "SUCCESS"
                        $removedCount++
                    }
                    catch {
                        Write-Log "Could not remove $($item.Desc): $($_.Exception.Message)" "WARNING"
                    }
                }
                else {
                    Write-Host "    Kept." -ForegroundColor Gray
                }
            }
        }
        default {
            Write-Log "Bloatware removal cancelled" "INFO"
        }
    }
    
    if ($removedCount -gt 0) {
        Write-Log "`nRemoved $removedCount app(s) total" "SUCCESS"
        Write-Host "  Tip: Some apps may reappear after Windows updates." -ForegroundColor DarkGray
        Write-Host "  Tip: Re-run this tool after major updates to clean them again." -ForegroundColor DarkGray
    }
    
    Wait-KeyPress
}

# ============================================
# 15. CLEAN OLD RESTORE POINTS
# ============================================
function Remove-OldRestorePoints {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "CLEAN OLD RESTORE POINTS" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Log "Scanning for restore points..." "STEP"
    
    try {
        # Using WMI ShadowCopy to manage individual deletions
        # Force array with @() — single results from Get-CimInstance aren't arrays
        $shadows = @(Get-CimInstance Win32_ShadowCopy -ErrorAction Stop | Sort-Object InstallDate)
        $count = $shadows.Count
        
        $keepCount = $Config.RestorePointsToKeep   # Defined in $Config at top of script
        
        if ($count -eq 0) {
            Write-Host "  No restore points found." -ForegroundColor Yellow
        }
        elseif ($count -le $keepCount) {
            Write-Host "  Only $count restore point(s) exist. Keeping all for safety (minimum $keepCount)." -ForegroundColor Yellow
        }
        else {
            $deleteCount = $count - $keepCount
            Write-Host "  Found $count restore points." -ForegroundColor White
            Write-Host "  Will keep the $keepCount newest and delete $deleteCount old point(s).`n" -ForegroundColor Yellow
            
            # Show what will be deleted vs kept
            $toDelete = $shadows[0..($count - $keepCount - 1)]
            $toKeep = $shadows[($count - $keepCount)..($count - 1)]
            
            foreach ($s in $toDelete) {
                Write-Host "    [DELETE] $($s.InstallDate)" -ForegroundColor Red
            }
            foreach ($s in $toKeep) {
                Write-Host "    [KEEP]   $($s.InstallDate)" -ForegroundColor Green
            }
            
            if (-not (Get-ValidYN "`n  Proceed with deletion?")) {
                Write-Log "Restore point cleanup cancelled by user" "WARNING"
                Wait-KeyPress
                return
            }
            
            $deletedOk = 0
            foreach ($shadow in $toDelete) {
                try {
                    Write-Host "  Deleting backup from $($shadow.InstallDate)..." -ForegroundColor Gray
                    # Use vssadmin — the reliable method (Invoke-CimMethod Delete is not supported on Win32_ShadowCopy)
                    $shadowId = $shadow.ID
                    $result = & vssadmin delete shadows /Shadow="$shadowId" /Quiet 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $deletedOk++
                    }
                    else {
                        Write-Log "Could not delete shadow copy: $result" "WARNING"
                    }
                }
                catch {
                    Write-Log "Could not delete shadow copy from $($shadow.InstallDate): $($_.Exception.Message)" "WARNING"
                }
            }
            
            Write-Log "Deleted $deletedOk of $deleteCount old restore points. Kept the $keepCount newest." "SUCCESS"
        }
    }
    catch {
        Write-Log "Error managing restore points: $($_.Exception.Message)" "ERROR"
    }
    
    Wait-KeyPress
}

# ============================================
# 16. DELETE OLD LOG FILES
# ============================================
function Remove-OldLogs {
    param([switch]$Auto)
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "CLEANUP SCRIPT LOGS & REPORTS" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    $patterns = @("Optimizer_Log_*.txt", "System_Health_*.txt", "battery-report.html")
    $days = $Config.LogCleanupDays
    
    # Check for files
    $foundFiles = Get-ChildItem -Path $desktopPath -Include $patterns -File -Recurse -ErrorAction SilentlyContinue
    
    if ($foundFiles.Count -eq 0) {
        Write-Host "  No script logs or reports found on Desktop." -ForegroundColor Green
        return
    }
    
    Write-Host "  Found $($foundFiles.Count) files generated by WinOptimizer." -ForegroundColor White
    
    $toDelete = @()
    
    if ($Auto) {
        # Auto mode: silently delete files older than configured days
        $limitDate = (Get-Date).AddDays(-$days)
        $toDelete = $foundFiles | Where-Object { $_.LastWriteTime -lt $limitDate }
        if ($toDelete.Count -gt 0) {
            Write-Log "Auto-cleaning files older than $days days..." "STEP"
        }
    }
    else {
        # Interactive mode: ask user what to do
        Write-Host "`n  What would you like to do?" -ForegroundColor Yellow
        Write-Host "    1. Delete OLD files only (older than $days days)" -ForegroundColor White
        Write-Host "    2. Delete ALL files (Clear history)" -ForegroundColor White
        Write-Host "    0. Cancel" -ForegroundColor Gray
        
        Write-Host "`n  Choice: " -ForegroundColor Yellow -NoNewline
        $choice = (Read-Host).Trim()
        
        switch ($choice) {
            "1" {
                $limitDate = (Get-Date).AddDays(-$days)
                $toDelete = $foundFiles | Where-Object { $_.LastWriteTime -lt $limitDate }
                if ($toDelete.Count -gt 0) {
                    Write-Log "Cleaning files older than $days days..." "STEP"
                }
            }
            "2" {
                $toDelete = $foundFiles
                Write-Log "Cleaning ALL script files..." "STEP"
            }
            default {
                Write-Host "  Cancelled." -ForegroundColor Gray
                return
            }
        }
    }
    
    if ($toDelete.Count -gt 0) {
        foreach ($file in $toDelete) {
            # Skip the file currently being written to
            if ($file.FullName -eq $logFile) {
                Write-Host "    Skipping active log file: $($file.Name)" -ForegroundColor Gray
                continue
            }
            
            try {
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                Write-Host "    Deleted: $($file.Name)" -ForegroundColor DarkGray
            }
            catch {
                Write-Host "    Failed to delete: $($file.Name)" -ForegroundColor Red
            }
        }
        Write-Host "`n  Cleanup complete. Removed $($toDelete.Count) files." -ForegroundColor Green
    }
    else {
        Write-Host "  No matching files found to delete." -ForegroundColor Green
    }
    
    Wait-KeyPress
}

# ============================================
# 17. SOFTWARE UPDATE MANAGER (WINGET)
# ============================================
function Update-Software {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "SOFTWARE UPDATE MANAGER (WINGET)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Check if winget is available
    Write-Log "Checking for winget..." "STEP"
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetCmd) {
        Write-Log "Winget is not installed or not in PATH" "WARNING"
        
        # ── Diagnose WHY winget is missing ──
        Write-Host "`n  Winget not found. Diagnosing..." -ForegroundColor Yellow
        
        $osBuild = [System.Environment]::OSVersion.Version.Build
        $isLTSC = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue).EditionID -match "LTSC|LTSB|Server"
        $hasStore = Get-AppxPackage -Name "Microsoft.WindowsStore" -ErrorAction SilentlyContinue
        $hasAppInstaller = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" -ErrorAction SilentlyContinue
        
        if ($isLTSC) {
            Write-Host "  Cause: Windows LTSC/LTSB detected (no Microsoft Store by default)" -ForegroundColor Red
            Write-Host "  Fix:   Download winget manually from:" -ForegroundColor Gray
            Write-Host "         https://github.com/microsoft/winget-cli/releases" -ForegroundColor Cyan
            Write-Host "         Install the .msixbundle file from the latest release." -ForegroundColor Gray
        }
        elseif (-not $hasStore) {
            Write-Host "  Cause: Microsoft Store is missing or disabled" -ForegroundColor Red
            Write-Host "  Fix:   Re-enable the Store via Group Policy or re-register it:" -ForegroundColor Gray
            Write-Host "         PowerShell: Get-AppxPackage *WindowsStore* | Foreach {Add-AppxPackage -Register `$(`$_.InstallLocation)\AppXManifest.xml}" -ForegroundColor DarkGray
        }
        elseif (-not $hasAppInstaller) {
            Write-Host "  Cause: App Installer package is missing (winget is bundled with it)" -ForegroundColor Red
        }
        elseif ($osBuild -lt 17763) {
            Write-Host "  Cause: Windows build $osBuild is too old (winget requires build 17763+)" -ForegroundColor Red
            Write-Host "  Fix:   Update Windows to version 1809 or later." -ForegroundColor Gray
        }
        else {
            Write-Host "  Cause: App Installer may need updating or re-registering" -ForegroundColor Red
        }
        
        # ── Offer one-click install from Microsoft Store ──
        if ($hasStore -and -not $isLTSC) {
            Write-Host ""
            if (Get-ValidYN "  Open Microsoft Store to install/update App Installer (winget)?") {
                Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
                Write-Log "Opened Microsoft Store for App Installer" "SUCCESS"
                Write-Host "  After installing, close and re-open this script." -ForegroundColor Gray
            }
        }
        
        # ── Fallback: still offer basic update checks without winget ──
        Write-Host "`n  --- Fallback Options (no winget needed) ---" -ForegroundColor DarkCyan
        Write-Host "    1 = Check pending Windows Updates" -ForegroundColor White
        Write-Host "    2 = Refresh Microsoft Store apps" -ForegroundColor White
        Write-Host "    0 = Back to menu" -ForegroundColor DarkGray
        Write-Host "  Choice: " -ForegroundColor Yellow -NoNewline
        $fallback = (Read-Host).Trim()
        
        switch ($fallback) {
            "1" {
                Write-Log "Checking pending Windows Updates..." "STEP"
                Write-Host "  Searching (this may take a moment)..." -ForegroundColor Gray
                try {
                    $updateSession = New-Object -ComObject Microsoft.Update.Session
                    $searcher = $updateSession.CreateUpdateSearcher()
                    $result = $searcher.Search("IsInstalled=0")
                    if ($result.Updates.Count -gt 0) {
                        Write-Host "`n  Pending Updates ($($result.Updates.Count)):" -ForegroundColor Yellow
                        foreach ($update in $result.Updates) {
                            $size = [math]::Round($update.MaxDownloadSize / 1MB, 1)
                            $severity = if ($update.MsrcSeverity) { " [$($update.MsrcSeverity)]" } else { "" }
                            Write-Host "    - $($update.Title)$severity [$size MB]" -ForegroundColor White
                        }
                        Write-Host ""
                        if (Get-ValidYN "  Open Windows Update to install these?") {
                            Start-Process "ms-settings:windowsupdate"
                            Write-Log "Opened Windows Update settings" "SUCCESS"
                        }
                    }
                    else {
                        Write-Log "Windows is fully up to date!" "SUCCESS"
                    }
                }
                catch {
                    Write-Log "Could not check Windows Updates: $($_.Exception.Message)" "WARNING"
                }
            }
            "2" {
                Write-Log "Refreshing Microsoft Store apps..." "STEP"
                Write-Host "  Triggering Store app updates (runs in background)..." -ForegroundColor Gray
                try {
                    Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" -ErrorAction Stop |
                    Invoke-CimMethod -MethodName "UpdateScanMethod" -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "Store app update scan triggered" "SUCCESS"
                    Write-Host "  Store apps will update in the background." -ForegroundColor Green
                    Write-Host "  Check Microsoft Store > Library for progress." -ForegroundColor Gray
                }
                catch {
                    # Fallback: open Store library page
                    Write-Host "  Auto-trigger not available. Opening Store Library..." -ForegroundColor Yellow
                    Start-Process "ms-windows-store://downloadsandupdates"
                    Write-Log "Opened Store downloads page" "SUCCESS"
                    Write-Host "  Click 'Get updates' in the Store to refresh all apps." -ForegroundColor Gray
                }
            }
        }
        
        Wait-KeyPress
        return
    }
    
    $wingetVersion = & winget --version 2>$null
    Write-Log "Winget found (version: $wingetVersion)" "SUCCESS"
    
    # Main menu when winget IS available
    Write-Host "  Options:" -ForegroundColor Yellow
    Write-Host "  1. Check for updates" -ForegroundColor White
    Write-Host "  2. Update ALL packages" -ForegroundColor White
    Write-Host "  3. Update a specific package" -ForegroundColor White
    Write-Host "  4. Search & install a new package" -ForegroundColor White
    Write-Host "  5. List installed packages" -ForegroundColor White
    Write-Host "  0. Back to menu" -ForegroundColor White
    Write-Host "`n  Choice (0-5): " -ForegroundColor Yellow -NoNewline
    $updateChoice = (Read-Host).Trim()
    
    switch ($updateChoice) {
        "1" {
            # List available updates
            Write-Log "Scanning for available updates..." "STEP"
            Write-Host "  This may take a moment...`n" -ForegroundColor Gray
            
            $upgradeOutput = & winget upgrade --include-unknown --accept-source-agreements 2>$null
            foreach ($line in $upgradeOutput) {
                Write-Host "  $line" -ForegroundColor White
            }
            
            # Count available updates - try multiple patterns for compatibility
            $availableCount = 0
            $upgradePattern = "(\d+)\s+upgrades?\s+available"
            $countLine = $upgradeOutput | Where-Object { $_ -match $upgradePattern } | Select-Object -Last 1
            if ($countLine -match $upgradePattern) {
                $availableCount = [int]$Matches[1]
            }
            else {
                # Fallback: count lines that look like package entries
                $count = 0
                foreach ($uline in $upgradeOutput) {
                    if ($uline.Trim().Length -gt 20 -and $uline -notlike "Name*" -and $uline -notlike "---*") { $count++ }
                }
                $availableCount = $count
            }
            
            if ($availableCount -gt 0) {
                Write-Host "`n  $availableCount update(s) available." -ForegroundColor Yellow
            }
            else {
                Write-Host "`n  All packages are up to date!" -ForegroundColor Green
            }
        }
        "2" {
            Write-Log "Updating all packages..." "STEP"
            Write-Host "`n  Updating all packages. This may take several minutes..." -ForegroundColor Gray
            Write-Host "  Some packages may show progress bars below.`n" -ForegroundColor DarkGray
            
            & winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements 2>$null
            
            # Winget exit codes: 0=success, other=partial failure (common and usually harmless)
            if ($LASTEXITCODE -eq 0) {
                Write-Log "All packages updated successfully!" "SUCCESS"
            }
            else {
                Write-Log "Update process completed (some packages may have been skipped)" "WARNING"
                Write-Host "  Note: Non-zero exit code ($LASTEXITCODE) is common when:" -ForegroundColor Gray
                Write-Host "    - A package has no newer version available" -ForegroundColor DarkGray
                Write-Host "    - A package requires manual update (e.g., from its own installer)" -ForegroundColor DarkGray
                Write-Host "    - A package was pinned to a specific version" -ForegroundColor DarkGray
            }
        }
        "3" {
            # First show available updates so user can see IDs
            Write-Host "`n  Scanning for available updates..." -ForegroundColor Gray
            $upgradeOutput = & winget upgrade --include-unknown --accept-source-agreements 2>$null
            foreach ($line in $upgradeOutput) {
                Write-Host "  $line" -ForegroundColor White
            }
            
            Write-Host "`n  Enter the package ID (from the list above): " -ForegroundColor Yellow -NoNewline
            $packageId = (Read-Host).Trim()
            if (-not [string]::IsNullOrEmpty($packageId)) {
                Write-Log "Updating $packageId..." "STEP"
                & winget upgrade --id $packageId --accept-source-agreements --accept-package-agreements 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "$packageId updated successfully!" "SUCCESS"
                }
                else {
                    Write-Log "Could not update $packageId (exit code: $LASTEXITCODE)" "WARNING"
                    Write-Host "  Tip: Check the package ID is correct. Use winget list to verify." -ForegroundColor Gray
                }
            }
            else {
                Write-Host "  No package ID entered. Skipped." -ForegroundColor Gray
            }
        }
        "4" {
            Write-Host "`n  Enter search term (app name or keyword): " -ForegroundColor Yellow -NoNewline
            $searchTerm = (Read-Host).Trim()
            if (-not [string]::IsNullOrEmpty($searchTerm)) {
                Write-Log "Searching for $searchTerm..." "STEP"
                Write-Host ""
                & winget search $searchTerm --accept-source-agreements 2>$null
                
                Write-Host "`n  Enter the package ID to install (or press Enter to cancel): " -ForegroundColor Yellow -NoNewline
                $installId = (Read-Host).Trim()
                if (-not [string]::IsNullOrEmpty($installId)) {
                    Write-Host ""
                    if (Get-ValidYN "  Install $($installId)?") {
                        Write-Log "Installing $installId..." "STEP"
                        & winget install --id $installId --accept-source-agreements --accept-package-agreements 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            Write-Log "$installId installed successfully!" "SUCCESS"
                        }
                        else {
                            Write-Log "Installation of $installId failed (exit code: $LASTEXITCODE)" "WARNING"
                        }
                    }
                }
                else {
                    Write-Host "  Cancelled." -ForegroundColor Gray
                }
            }
            else {
                Write-Host "  No search term entered." -ForegroundColor Gray
            }
        }
        "5" {
            Write-Log "Listing installed packages..." "STEP"
            Write-Host "  Loading...`n" -ForegroundColor Gray
            & winget list --accept-source-agreements 2>$null
        }
        "0" {
            return
        }
        default {
            Write-Host "  Invalid choice." -ForegroundColor Red
        }
    }
    
    Wait-KeyPress
}

# ============================================
# 18. REPAIR WINDOWS (SFC + DISM)
# ============================================
function Repair-Windows {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "REPAIR WINDOWS SYSTEM FILES" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "  Choose a repair option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Full Repair (DISM + SFC + Component Cleanup)" -ForegroundColor White
    Write-Host "     Best for: Corrupted Windows, update failures, blue screens" -ForegroundColor DarkGray
    Write-Host "     Time: 15-30 minutes" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  2. Quick Scan (SFC only)" -ForegroundColor White
    Write-Host "     Best for: Minor file corruption, quick check" -ForegroundColor DarkGray
    Write-Host "     Time: 5-15 minutes" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  3. Image Repair (DISM only)" -ForegroundColor White
    Write-Host "     Best for: When SFC reports it cannot fix files" -ForegroundColor DarkGray
    Write-Host "     Time: 10-20 minutes" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  4. Disk Check (schedule chkdsk on next restart)" -ForegroundColor White
    Write-Host "     Best for: Disk errors, bad sectors, file system corruption" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  5. View Recent System Errors" -ForegroundColor White
    Write-Host "     Best for: Diagnosing crashes and failures" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  0. Back to menu" -ForegroundColor White
    Write-Host "`n  Choice (0-5): " -ForegroundColor Yellow -NoNewline
    $repairChoice = (Read-Host).Trim()
    
    $ranRepair = $false
    
    switch ($repairChoice) {
        "1" {
            Write-Host "`n  This will run DISM + SFC + Component Cleanup." -ForegroundColor Yellow
            Write-Host "  Estimated time: 15-30 minutes." -ForegroundColor Gray
            if (-not (Get-ValidYN "`n  Continue?")) { return }
            
            # DISM
            Write-Log "`n[1/3] Running DISM (Repair Windows Image)..." "STEP"
            Write-Host "  This may take 10-15 minutes. Progress will show below...`n" -ForegroundColor Gray
            
            $dismResult = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -NoNewWindow
            
            if ($dismResult.ExitCode -eq 0) {
                Write-Log "DISM repair completed successfully" "SUCCESS"
            }
            else {
                Write-Log "DISM completed with exit code: $($dismResult.ExitCode)" "WARNING"
                Write-Host "    Tip: If DISM failed, ensure you have an internet connection" -ForegroundColor Gray
                Write-Host "    Alternative: Use a Windows ISO as source:" -ForegroundColor Gray
                Write-Host "    DISM /Online /Cleanup-Image /RestoreHealth /Source:WIM:D:\sources\install.wim:1" -ForegroundColor DarkGray
            }
            
            # SFC
            Write-Log "`n[2/3] Running SFC (System File Checker)..." "STEP"
            Write-Host "  This may take 5-15 minutes...`n" -ForegroundColor Gray
            
            $sfcResult = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow
            
            if ($sfcResult.ExitCode -eq 0) {
                Write-Log "SFC scan completed successfully" "SUCCESS"
            }
            else {
                Write-Log "SFC completed with exit code: $($sfcResult.ExitCode)" "WARNING"
                Write-Host "    Tip: If SFC found issues it couldn't fix, re-run DISM first, then SFC again" -ForegroundColor Gray
                Write-Host "    Check: C:\Windows\Logs\CBS\CBS.log for detailed SFC results" -ForegroundColor Gray
            }
            
            # Component Store Cleanup
            Write-Log "`n[3/3] Analyzing Component Store..." "STEP"
            $analyzeResult = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /AnalyzeComponentStore" -Wait -PassThru -NoNewWindow
            
            if ($analyzeResult.ExitCode -eq 0) {
                Write-Log "Component store analysis complete" "SUCCESS"
                
                if (Get-ValidYN "`n  Clean up component store? (frees disk space)") {
                    $cleanResult = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /ResetBase" -Wait -PassThru -NoNewWindow
                    if ($cleanResult.ExitCode -eq 0) {
                        Write-Log "Component store cleaned up successfully" "SUCCESS"
                    }
                    else {
                        Write-Log "Component cleanup finished with exit code: $($cleanResult.ExitCode)" "WARNING"
                    }
                }
            }
            else {
                Write-Log "Component store analysis failed (exit code: $($analyzeResult.ExitCode))" "WARNING"
            }
            
            $ranRepair = $true
        }
        "2" {
            Write-Host "`n  Running SFC (System File Checker)..." -ForegroundColor Yellow
            Write-Host "  This may take 5-15 minutes. Progress will show below...`n" -ForegroundColor Gray
            
            $sfcResult = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow
            
            if ($sfcResult.ExitCode -eq 0) {
                Write-Log "SFC scan completed successfully -- no integrity violations found" "SUCCESS"
            }
            else {
                Write-Log "SFC completed with exit code: $($sfcResult.ExitCode)" "WARNING"
                Write-Host "    Tip: If SFC found issues, run Option 1 (Full Repair) to fix the image first" -ForegroundColor Gray
                Write-Host "    Check: C:\Windows\Logs\CBS\CBS.log for detailed results" -ForegroundColor Gray
            }
            
            $ranRepair = $true
        }
        "3" {
            Write-Host "`n  Running DISM (Repair Windows Image)..." -ForegroundColor Yellow
            Write-Host "  This may take 10-20 minutes. Progress will show below...`n" -ForegroundColor Gray
            
            $dismResult = Start-Process -FilePath "dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -NoNewWindow
            
            if ($dismResult.ExitCode -eq 0) {
                Write-Log "DISM image repair completed successfully" "SUCCESS"
                Write-Host "  Tip: Now run SFC (Option 2) to verify system files are intact" -ForegroundColor Gray
            }
            else {
                Write-Log "DISM completed with exit code: $($dismResult.ExitCode)" "WARNING"
                Write-Host "    Tip: Ensure internet connection is active for Windows Update source" -ForegroundColor Gray
            }
            
            $ranRepair = $true
        }
        "4" {
            Write-Host "`n  This will schedule a disk check on the next restart." -ForegroundColor Yellow
            Write-Host "  The check runs BEFORE Windows boots and may take 30-60 minutes." -ForegroundColor Gray
            
            if (Get-ValidYN "`n  Schedule disk check on C: for next restart?") {
                try {
                    & cmd /c "echo Y | chkdsk C: /F /R /X" 2>&1 | Out-Null
                    # chkdsk on the system drive always says "cannot lock" and schedules for reboot
                    Write-Log "Disk check scheduled for next restart" "SUCCESS"
                    Write-Host "  The check will run automatically on your next restart." -ForegroundColor Green
                    Write-Host "  Do NOT interrupt the check -- let it complete fully." -ForegroundColor Yellow
                    $ranRepair = $true
                }
                catch {
                    Write-Log "Could not schedule disk check: $($_.Exception.Message)" "WARNING"
                }
            }
        }
        "5" {
            Write-Host "`n  Recent System Errors (last 24 hours):" -ForegroundColor Yellow
            Write-Host "  (These are pre-existing errors, not caused by this tool)`n" -ForegroundColor DarkGray
            try {
                $errors = Get-WinEvent -FilterHashtable @{
                    LogName   = 'System'
                    Level     = 2  # Error
                    StartTime = (Get-Date).AddHours(-24)
                } -MaxEvents 10 -ErrorAction SilentlyContinue
                
                if ($errors) {
                    foreach ($evt in $errors) {
                        $msg = if ($evt.Message) { $evt.Message.Substring(0, [Math]::Min(100, $evt.Message.Length)) } else { "(No message)" }
                        $timeStr = $evt.TimeCreated.ToString('HH:mm')
                        $source = $evt.ProviderName
                        Write-Host "  [$timeStr] [$source]" -ForegroundColor Red -NoNewline
                        Write-Host " $msg" -ForegroundColor White
                    }
                    Write-Host "`n  Total: $($errors.Count) error(s) in the last 24 hours" -ForegroundColor Gray
                }
                else {
                    Write-Host "  No system errors in the last 24 hours!" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "  Could not read event logs" -ForegroundColor Gray
                Write-Host "  Tip: Event Log service may be disabled or logs may be cleared" -ForegroundColor DarkGray
            }
        }
        "0" {
            return
        }
        default {
            Write-Host "  Invalid choice." -ForegroundColor Red
        }
    }
    
    # Offer restart if a repair was performed
    if ($ranRepair) {
        Write-Log "`nWindows repair process complete!" "SUCCESS"
        Write-Host ""
        if (Get-ValidYN "  A restart is recommended after repairs. Restart now?") {
            Write-Host "`n  Restarting in 10 seconds... Press Ctrl+C to cancel" -ForegroundColor Yellow
            for ($i = 10; $i -gt 0; $i--) {
                Write-Host "`r  Restarting in $i seconds...  " -ForegroundColor Yellow -NoNewline
                Start-Sleep -Seconds 1
            }
            Restart-Computer -Force
        }
    }
    
    Wait-KeyPress
}

# ============================================
# 19. CREATE RESTORE POINT
# ============================================
function New-RestorePoint {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "CREATE SYSTEM RESTORE POINT" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Show existing restore points
    Write-Log "Existing restore points:" "STEP"
    try {
        $restorePoints = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        if ($restorePoints) {
            foreach ($rp in $restorePoints | Select-Object -Last 5) {
                Write-Host "  [$($rp.SequenceNumber)] $($rp.Description) - $($rp.CreationTime)" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  No existing restore points found" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Could not retrieve restore points" -ForegroundColor Gray
    }
    
    if (Get-ValidYN "`nCreate new restore point?") {
        Write-Host "Enter description (or press Enter for default): " -ForegroundColor Yellow -NoNewline
        $desc = Read-Host
        if ([string]::IsNullOrEmpty($desc)) {
            $desc = "Manual Restore Point - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }
        
        New-SafeRestorePoint -Description $desc
    }
    
    Wait-KeyPress
}

# ============================================
# 20. RUN ALL OPTIMIZATIONS
# ============================================
function Invoke-AllOptimizations {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "RUN ALL OPTIMIZATIONS (SAFE MODE)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "This will run the following optimizations:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  STEP 1: Create System Restore Point (Safety net)" -ForegroundColor White
    Write-Host "  STEP 2: Optimize Windows Services" -ForegroundColor White
    Write-Host "       -> Disable 7 telemetry/bloat services (DiagTrack, MapsBroker, etc.)" -ForegroundColor DarkGray
    Write-Host "       -> Smart detection: keeps Spooler if printers found, WbioSrvc if biometric" -ForegroundColor DarkGray
    Write-Host "  STEP 3: Optimize Startup Programs" -ForegroundColor White
    Write-Host "       -> Scan registry for non-essential startup entries" -ForegroundColor DarkGray
    Write-Host "       -> Disable matching scheduled tasks (with protected whitelist)" -ForegroundColor DarkGray
    Write-Host "  STEP 4: Optimize RAM & Performance" -ForegroundColor White
    Write-Host "       -> Trim idle process working sets (skip 22 protected processes)" -ForegroundColor DarkGray
    Write-Host "       -> Disable animations, set High Performance power plan" -ForegroundColor DarkGray
    Write-Host "  STEP 5: Privacy & Telemetry Shield" -ForegroundColor White
    Write-Host "       -> Apply 15+ privacy registry settings (telemetry, ad ID, location)" -ForegroundColor DarkGray
    Write-Host "  STEP 6: Deep Disk Cleanup" -ForegroundColor White
    Write-Host "       -> Clear temp files, browser caches (12 browsers), Windows Update cache" -ForegroundColor DarkGray
    Write-Host "       -> Old logs, thumbnails + SSD TRIM / HDD Defrag" -ForegroundColor DarkGray
    Write-Host "  STEP 7: Fix Network Issues" -ForegroundColor White
    Write-Host "       -> Flush DNS, optimize TCP, configure DNS provider" -ForegroundColor DarkGray
    Write-Host "       -> VPN/VM adapters auto-detected and protected" -ForegroundColor DarkGray
    Write-Host "  STEP 8: Cleanup Old Logs & Reports" -ForegroundColor White
    Write-Host "       -> Auto-delete script logs/reports older than $($Config.LogCleanupDays) days" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Estimated time: 5-15 minutes" -ForegroundColor Gray
    Write-Host ""
    do {
        Write-Host "Continue? (Y/N): " -ForegroundColor Yellow -NoNewline
        $response = Read-Host
    } while ($response -notmatch '^[YyNn]$')
    
    if ($response -match '^[Nn]$') {
        return
    }
    
    $totalSteps = 8
    $startTime = Get-Date
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "STARTING FULL OPTIMIZATION..." -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    
    $script:skipPause = $true
    $script:LoggingEnabled = $true
    
    $stepNames = @(
        "Creating Restore Point",
        "Optimizing Services",
        "Optimizing Startup",
        "Optimizing RAM & Performance",
        "Applying Privacy Shield",
        "Deep Cleaning Disk",
        "Fixing Network",
        "Cleaning Old Logs & Reports"
    )
    
    # Step functions with error resilience
    $stepFunctions = @(
        { New-SafeRestorePoint },
        { Optimize-Services },
        { Optimize-Startup },
        { Optimize-RAM },
        { Set-PrivacyShield },
        { Invoke-DiskCleanup -Auto },
        { Repair-Network },
        { Remove-OldLogs -Auto }
    )
    
    $completedSteps = 0
    $failedSteps = @()
    
    for ($s = 0; $s -lt $totalSteps; $s++) {
        $stepNum = $s + 1
        Write-Host "`n  >>> [$stepNum/$totalSteps] $($stepNames[$s])..." -ForegroundColor Cyan
        
        try {
            & $stepFunctions[$s]
            $completedSteps++
        }
        catch {
            Write-Log "Step $stepNum ($($stepNames[$s])) failed: $($_.Exception.Message)" "ERROR"
            $failedSteps += $stepNames[$s]
            if ($stepNum -lt $totalSteps) {
                if (-not (Get-ValidYN "  Step failed. Continue with remaining steps?")) {
                    Write-Log "Optimization aborted by user after step $stepNum failure" "WARNING"
                    break
                }
            }
        }
    }
    
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    $script:skipPause = $false
    $script:LoggingEnabled = $false
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "ALL OPTIMIZATIONS COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Completed: $completedSteps/$totalSteps steps" -ForegroundColor Gray
    if ($failedSteps.Count -gt 0) {
        Write-Host "  Failed: $($failedSteps -join ', ')" -ForegroundColor Red
    }
    Write-Host "  Duration: $($duration.Minutes) minutes $($duration.Seconds) seconds" -ForegroundColor Gray
    Write-Host "  Log file: $logFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "IMPORTANT: Restart your laptop for all changes to take effect!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Restart now? (Y/N): " -ForegroundColor Yellow -NoNewline
    do {
        $restart = Read-Host
        if ($restart -notmatch '^[YyNn]$') {
            Write-Host "  Please enter Y or N: " -ForegroundColor Yellow -NoNewline
        }
    } while ($restart -notmatch '^[YyNn]$')
    
    if ($restart -match '^[Yy]$') {
        Write-Host "`nRestarting in 15 seconds... Press Ctrl+C to cancel" -ForegroundColor Yellow
        for ($i = 15; $i -gt 0; $i--) {
            Write-Host "`r  Restarting in $i seconds...  " -ForegroundColor Yellow -NoNewline
            Start-Sleep -Seconds 1
        }
        Restart-Computer -Force
    }
    
    Wait-KeyPress
}

# ============================================
# MAIN PROGRAM LOOP
# ============================================
Write-Log "=== Optimizer v$scriptVersion started ===" "INFO"
Write-Log "User: $env:USERNAME | Computer: $env:COMPUTERNAME" "INFO"

do {
    Show-Menu
    Write-Host "Enter your choice (0-20, H for help): " -ForegroundColor Yellow -NoNewline
    $choice = (Read-Host).Trim()
    
    switch ($choice) {
        "1" { Get-SystemInfo }
        "2" { Get-QuickStatus }
        "3" { Get-HeavyProcesses }
        "4" { Get-BatteryHealth }
        "5" { Get-DiskHealth }
        "6" { Get-StorageAnalysis }
        "7" { Optimize-Startup }
        "8" { Optimize-RAM }
        "9" { Optimize-Services }
        "10" { Repair-Network }
        "11" { Set-PrivacyShield }
        "12" { Invoke-WindowsUpdateManager }
        "13" { Invoke-DiskCleanup }
        "14" { Remove-Bloatware }
        "15" { Remove-OldRestorePoints }
        "16" { Remove-OldLogs }
        "17" { Update-Software }
        "18" { Repair-Windows }
        "19" { New-RestorePoint }
        "20" { Invoke-AllOptimizations }
        { $_ -eq "H" -or $_ -eq "h" } {
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host "   HELP - What Each Option Does" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  DIAGNOSTICS & ANALYSIS:" -ForegroundColor Yellow
            Write-Host "   1. Full System Health Report" -ForegroundColor White
            Write-Host "      10-section report: OS, CPU, RAM, disk, GPU, startup," -ForegroundColor Gray
            Write-Host "      services, network, license status. Saved to Desktop." -ForegroundColor Gray
            Write-Host "   2. Quick RAM & CPU Check" -ForegroundColor White
            Write-Host "      Instant snapshot with visual bars, uptime, process count." -ForegroundColor Gray
            Write-Host "   3. Identify Heavy Processes" -ForegroundColor White
            Write-Host "      Top 15 by RAM, browser totals, option to kill by PID." -ForegroundColor Gray
            Write-Host "   4. Battery Health Report" -ForegroundColor White
            Write-Host "      Windows battery report (powercfg), charge capacity, cycles." -ForegroundColor Gray
            Write-Host "   5. Disk & Hardware Health" -ForegroundColor White
            Write-Host "      S.M.A.R.T. data, temperatures, reliability counters," -ForegroundColor Gray
            Write-Host "      fragmentation analysis." -ForegroundColor Gray
            Write-Host "   6. Storage Space Analyzer" -ForegroundColor White
            Write-Host "      Scans 12 key folders with visual bars. Shows recommendations" -ForegroundColor Gray
            Write-Host "      for Downloads, temp/cache, browser data, low disk space." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  PERFORMANCE & TWEAKS:" -ForegroundColor Yellow
            Write-Host "   7. Optimize Startup" -ForegroundColor White
            Write-Host "      Scans & disables bloatware startup entries + related tasks." -ForegroundColor Gray
            Write-Host "      Database of 80+ known non-essential programs." -ForegroundColor Gray
            Write-Host "   8. Optimize RAM & Performance" -ForegroundColor White
            Write-Host "      Trims idle working sets (EmptyWorkingSet API), disables" -ForegroundColor Gray
            Write-Host "      animations, High Performance power plan, Game DVR, Cortana." -ForegroundColor Gray
            Write-Host "   9. Optimize Windows Services" -ForegroundColor White
            Write-Host "      Disables telemetry, maps, retail demo services. SSD/HDD" -ForegroundColor Gray
            Write-Host "      auto-detect for Superfetch. Tunes Defender CPU." -ForegroundColor Gray
            Write-Host "  10. Fix Network Issues" -ForegroundColor White
            Write-Host "      DNS flush, TCP/IP reset (skips VPN/VM adapters), IP renew," -ForegroundColor Gray
            Write-Host "      TCP tuning, DNS provider (Google/Cloudflare/Quad9)." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  PRIVACY & SECURITY:" -ForegroundColor Yellow
            Write-Host "  11. Privacy & Telemetry Shield" -ForegroundColor White
            Write-Host "      15+ settings across 8 categories: telemetry, ad ID," -ForegroundColor Gray
            Write-Host "      location, Bing search, activity history, clipboard sync." -ForegroundColor Gray
            Write-Host "  12. Windows Update Manager" -ForegroundColor White
            Write-Host "      Check/pause (1-$($Config.MaxUpdatePauseDays) days), resume, set active hours," -ForegroundColor Gray
            Write-Host "      clear stuck update cache." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  CLEANING & DEBLOATING:" -ForegroundColor Yellow
            Write-Host "  13. Deep Disk Clean" -ForegroundColor White
            Write-Host "      7-step cleanup: temp, 12 browser caches, WU cache, old" -ForegroundColor Gray
            Write-Host "      logs, thumbnails, CleanMgr, SSD TRIM / HDD defrag." -ForegroundColor Gray
            Write-Host "  14. Bloatware Uninstaller" -ForegroundColor White
            Write-Host "      2-tier scan: definite junk (30+) + popular apps (25+)." -ForegroundColor Gray
            Write-Host "      4 modes: junk only, all, junk+choose, individual Y/N." -ForegroundColor Gray
            Write-Host "  15. Clean Old Restore Points" -ForegroundColor White
            Write-Host "      Deletes all but the $($Config.RestorePointsToKeep) newest restore points to free space." -ForegroundColor Gray
            Write-Host "  16. Cleanup Script Logs & Reports" -ForegroundColor White
            Write-Host "      Deletes optimizer logs, health reports, and battery reports." -ForegroundColor Gray
            Write-Host "      Remove old files (>$($Config.LogCleanupDays) days) or clear all history." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  MAINTENANCE & REPAIRS:" -ForegroundColor Yellow
            Write-Host "  17. Software Update Manager" -ForegroundColor White
            Write-Host "      Winget: check, update all, update specific, search & install," -ForegroundColor Gray
            Write-Host "      list installed. Fallback mode if winget is missing." -ForegroundColor Gray
            Write-Host "  18. Repair Windows" -ForegroundColor White
            Write-Host "      5 options: Full (DISM+SFC+Cleanup), Quick SFC, DISM only," -ForegroundColor Gray
            Write-Host "      schedule chkdsk, view recent system errors." -ForegroundColor Gray
            Write-Host "  19. Create Restore Point" -ForegroundColor White
            Write-Host "      Creates a verified system restore point with custom name." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  AUTOMATION:" -ForegroundColor Yellow
            Write-Host "  20. Run ALL Optimizations" -ForegroundColor White
            Write-Host "      8-step pipeline: Restore Point, Services, Startup, RAM," -ForegroundColor Gray
            Write-Host "      Privacy, Disk Clean, Network, Log Cleanup. Error resilient." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  GitHub: https://github.com/Prakhar0206/WinOptimizer" -ForegroundColor DarkCyan
            Write-Host ""
            Wait-KeyPress
        }
        "0" { 
            $exitMsg1 = "Thanks for using the Optimizer v$scriptVersion!"
            $exitMsg2 = "Keep your laptop running smoothly!"
            Write-Host ""
            Write-Host "   +============================================+" -ForegroundColor Green
            Write-Host "   |  $($exitMsg1.PadRight(42))|" -ForegroundColor Green
            Write-Host "   |  $($exitMsg2.PadRight(42))|" -ForegroundColor Green
            Write-Host "   +============================================+" -ForegroundColor Green
            Write-Host ""
            Write-Host "   Log: $logFile" -ForegroundColor DarkGray
            Write-Log "=== Optimizer closed ===" "INFO"
            Start-Sleep -Seconds 2
            exit
        }
        default {
            Write-Host "`nInvalid choice. Please enter 0-20 or H for help." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
    
} while ($true)
