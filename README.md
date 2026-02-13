<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Windows 10 | 11">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-3.3-orange" alt="Version 3.3">
</p>

# 🚀 WinOptimizer

**The Ultimate Windows 10/11 Optimization & Maintenance Tool**

A comprehensive, all-in-one PowerShell utility to optimize, debloat, and maintain Windows. 20 powerful tools packed into a single script — designed for power users who want maximum performance and privacy with minimal effort.

---

## ✨ Features (20 Tools)

### 📊 Diagnostics (Read-Only)
| # | Tool | What It Does |
|---|------|-------------|
| 1 | **System Health Report** | 10-section report: OS, CPU, RAM, disk, GPU, startup programs, services, network, license status. Saved to Desktop. |
| 2 | **Quick RAM & CPU Check** | Instant snapshot with visual bars, system uptime, and process count. |
| 3 | **Heavy Process Finder** | Top 15 processes by RAM, browser memory totals, option to kill by PID. |
| 4 | **Battery Health Report** | Windows `powercfg` battery report with charge capacity and cycle data. |
| 5 | **Disk & Hardware Health** | S.M.A.R.T. data, drive temperatures, reliability counters, fragmentation analysis. |

### ⚡ Optimization
| # | Tool | What It Does |
|---|------|-------------|
| 6 | **Startup Optimizer** | Database of 80+ known non-essential programs. Disables bloatware startup entries + related scheduled tasks. |
| 7 | **RAM & Performance** | Trims idle working sets (EmptyWorkingSet API), disables animations, sets High Performance power plan, disables Game DVR & Cortana. |
| 8 | **Deep Disk Clean** | 7-step cleanup: temp files, 12 browser caches, Windows Update cache, old logs, thumbnail cache, CleanMgr, SSD TRIM / HDD defrag. |
| 9 | **Network Repair** | DNS flush, TCP/IP reset (auto-skips VPN/VM adapters), IP renew, TCP tuning, DNS provider config (Google/Cloudflare/Quad9). |
| 10 | **Service Optimization** | Disables telemetry, maps, retail demo services. Auto-detects SSD/HDD for Superfetch decision. Tunes Defender CPU usage. |
| 11 | **Privacy Shield** | 15+ registry settings across 8 categories: telemetry, advertising ID, location, Bing search, activity history, cloud clipboard sync. |
| 12 | **Update Manager** | Check/pause Windows Updates (1-35 days), resume, set active hours, clear stuck update cache. |

### 🔧 Repair & Maintenance
| # | Tool | What It Does |
|---|------|-------------|
| 13 | **Repair Windows** | 5 options: Full DISM+SFC+Cleanup, Quick SFC, DISM only, schedule chkdsk, view recent system errors. |
| 14 | **Create Restore Point** | Creates a verified system restore point with custom name and shadow copy validation. |
| 15 | **Clean Restore Points** | Deletes old restore points, keeps the 2 newest. Uses `vssadmin` for reliable deletion. |
| 16 | **Cleanup Logs** | Deletes optimizer logs, health reports, and battery reports. Age-based (>30 days) or full cleanup. |

### 🎯 All-in-One & Extras
| # | Tool | What It Does |
|---|------|-------------|
| 17 | **Run ALL Optimizations** | 8-step pipeline with error resilience: Restore Point → Services → Startup → RAM → Privacy → Disk → Network → Log Cleanup. |
| 18 | **Software Updater** | Winget integration: check updates, update all/specific, search & install new apps, list installed. Fallback mode when winget is missing. |
| 19 | **Bloatware Uninstaller** | 2-tier scan: 30+ definite junk (Candy Crush, trial AV, etc.) + 25+ popular apps. 4 removal modes with protected whitelist. |
| 20 | **Storage Analyzer** | Scans 12 key folders with visual size bars. Recommendations for Downloads, temp/cache, browser data, low disk space. |

---

## 📥 Installation

1. **Download** the [latest release](https://github.com/Prakhar0206/WinOptimizer/releases) or clone:
   ```bash
   git clone https://github.com/Prakhar0206/WinOptimizer.git
   ```
2. **Unzip** to any folder (e.g., `C:\Tools\WinOptimizer`).

That's it — no dependencies to install.

---

## ⚡ How to Run

### Method 1: Batch Launcher (Recommended)
Double-click **`Run-Optimizer.bat`**  
→ Automatically requests Admin privileges and bypasses execution policy.

### Method 2: PowerShell
Right-click **PowerShell** → **Run as Administrator**, then:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WinOptimizer.ps1
```

---

## ⚙️ Configuration

All thresholds are configurable via the `$Config` block at the top of `WinOptimizer.ps1`:

```powershell
$Config = @{
    RamTrimThresholdMB    = 50    # Only trim processes using more than this (MB)
    LogCleanupDays        = 30    # Delete logs/reports older than this (days)
    RestorePointsToKeep   = 2     # How many restore points to keep
    MaxUpdatePauseDays    = 35    # Max days a user can pause updates
    DefenderMaxCpuPercent = 15    # Defender CPU limit during scans (5-50)
    DnsProviders = @{             # DNS options for network repair
        Google     = @("8.8.8.8", "8.8.4.4")
        Cloudflare = @("1.1.1.1", "1.0.0.1")
        Quad9      = @("9.9.9.9", "149.112.112.112")
    }
}
```

---

## 🔒 Safety Features

| Feature | How It Protects You |
|---------|-------------------|
| **Restore Points** | Prompts to create a system restore point before making changes. |
| **Protected Processes** | 22 critical system processes (csrss, lsass, dwm, explorer, etc.) are never trimmed. |
| **Protected Startup** | Drivers, security software, and system essentials are whitelisted and never disabled. |
| **VPN/VM Detection** | Auto-detects 17 VPN/VM adapter patterns and skips destructive network resets. |
| **SSD/HDD Detection** | 4 fallback detection methods to ensure correct optimization strategy. |
| **Domain Detection** | Preserves network policies on domain-joined PCs (skips DNS changes). |
| **User Confirmation** | Destructive operations always prompt Y/N before proceeding. |

---

## 📂 Project Structure

```
WinOptimizer/
├── WinOptimizer.ps1      # Main script (3,600+ lines, 20 tools)
├── Run-Optimizer.bat      # One-click launcher with admin elevation
├── LICENSE                # MIT License
├── .gitignore             # Ignores logs, temp files, IDE config
└── README.md              # This file
```

---

## ⚠️ Requirements

- **OS:** Windows 10 or Windows 11 (Home / Pro / Enterprise)
- **PowerShell:** 5.1 or newer (pre-installed on Windows 10/11)
- **Privileges:** Administrator (required for system-level changes)
- **Optional:** [Winget](https://github.com/microsoft/winget-cli) for Software Update Manager (Option 18)

---

## 📄 License

[MIT License](LICENSE) — Free to use, modify, and distribute.

---

## 👤 Author

**Prakhar Aggarwal**  
GitHub: [@Prakhar0206](https://github.com/Prakhar0206)

---

<p align="center">
  <b>⭐ If this tool helped you, consider giving it a star!</b>
</p>
