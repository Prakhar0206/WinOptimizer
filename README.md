<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell&logoColor=white" alt="PowerShell 5.1+">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Windows 10 | 11">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-3.4-orange" alt="Version 3.4">
</p>

# 🚀 WinOptimizer

**The Ultimate Windows 10/11 Optimization & Maintenance Tool**

A comprehensive, all-in-one PowerShell utility to optimize, debloat, and maintain Windows. 20 powerful tools packed into a single script — designed for power users who want maximum performance and privacy with minimal effort.

---

## ✨ Features (20 Tools)

### 📊 Diagnostics & Analysis (Read-Only)

| #   | Tool                          | What It Does                                                                                                       |
| --- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1   | **Full System Health Report** | 10-section report: OS, CPU, RAM, disk, GPU, startup programs, services, network, license status. Saved to Desktop. |
| 2   | **Quick RAM & CPU Check**     | Instant snapshot with visual bars, system uptime, and process count.                                               |
| 3   | **Identify Heavy Processes**  | Top 15 processes by RAM usage. Option to safely kill any process by PID.                                           |
| 4   | **Battery Health Report**     | Generates Windows `powercfg` battery report with charge capacity and cycle data.                                   |
| 5   | **Disk & Hardware Health**    | S.M.A.R.T. data, drive temperatures, reliability counters, and fragmentation analysis.                             |
| 6   | **Storage Space Analyzer**    | Scans 12 key folders with visual size bars. Gives tailored recommendations for low disk space.                     |

### 🚀 Performance & Tweaks

| #   | Tool                           | What It Does                                                                                               |
| --- | ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| 7   | **Smart Startup Optimizer**    | Scans and disables bloatware startup entries using a database of 80+ known non-essential programs.         |
| 8   | **Optimize RAM & Performance** | Trims idle working sets, disables animations, sets High Performance power plan, disables Game DVR/Cortana. |
| 9   | **Optimize Windows Services**  | Safely disables telemetry, maps, etc. Auto-detects SSD/HDD for Superfetch. Tunes Defender CPU limits.      |
| 10  | **Fix Network Issues**         | DNS flush, TCP/IP reset (auto-skips VPNs), IP renew, TCP tuning, and custom DNS (Google/Cloudflare/Quad9). |

### 🛡️ Privacy & Security

| #   | Tool                           | What It Does                                                                                                 |
| --- | ------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| 11  | **Privacy & Telemetry Shield** | 15+ registry settings across 8 categories: telemetry, advertising ID, location, Bing search, clipboard sync. |
| 12  | **Windows Update Manager**     | Check/pause Windows Updates (1-35 days), resume, configure active hours, clear stuck update caches.          |

### 🧹 Cleaning & Debloating

| #   | Tool                         | What It Does                                                                                                    |
| --- | ---------------------------- | --------------------------------------------------------------------------------------------------------------- |
| 13  | **Deep Disk Clean**          | 7-step cleanup: temp files, 12 browser caches, Windows Update cache, old logs, CleanMgr, SSD TRIM / HDD defrag. |
| 14  | **Bloatware Uninstaller**    | 2-tier scan (junk + popular apps). 4 removal modes (junk only, all, choose, prompt) to uninstall UWP bloatware. |
| 15  | **Clean Old Restore Points** | Reclaims disk space by deleting old restore points while keeping the most recent reliable states.               |
| 16  | **Delete Old Log Files**     | Cleans up optimizer execution logs, health reports, and battery reports older than your set threshold.          |

### 🛠️ Maintenance & Repairs

| #   | Tool                          | What It Does                                                                                         |
| --- | ----------------------------- | ---------------------------------------------------------------------------------------------------- |
| 17  | **Software Update (Winget)**  | Check updates, update all/specific apps, search & install. Has a fallback mode if Winget is missing. |
| 18  | **Repair Windows (SFC+DISM)** | 5 options: Full DISM+SFC+Cleanup, Quick SFC, DISM only, schedule chkdsk, view recent system errors.  |
| 19  | **Create Restore Point**      | Instantly creates a verified system restore point with a custom name.                                |

### ⚡ Automation

| #   | Tool                      | What It Does                                                                                               |
| --- | ------------------------- | ---------------------------------------------------------------------------------------------------------- |
| 20  | **RUN ALL OPTIMIZATIONS** | Master 8-step pipeline: Restore Point → Services → Startup → RAM → Privacy → Disk → Network → Log Cleanup. |

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

| Feature                 | How It Protects You                                                                   |
| ----------------------- | ------------------------------------------------------------------------------------- |
| **Restore Points**      | Prompts to create a system restore point before making changes.                       |
| **Protected Processes** | 22 critical system processes (csrss, lsass, dwm, explorer, etc.) are never trimmed.   |
| **Protected Startup**   | Drivers, security software, and system essentials are whitelisted and never disabled. |
| **VPN/VM Detection**    | Auto-detects 17 VPN/VM adapter patterns and skips destructive network resets.         |
| **SSD/HDD Detection**   | 4 fallback detection methods to ensure correct optimization strategy.                 |
| **Domain Detection**    | Preserves network policies on domain-joined PCs (skips DNS changes).                  |
| **User Confirmation**   | Destructive operations always prompt Y/N before proceeding.                           |

---

## 📂 Project Structure

```
WinOptimizer/
├── WinOptimizer.ps1      # Main script (3,900+ lines, 20 tools)
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
