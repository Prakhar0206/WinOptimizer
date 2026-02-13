# WinOptimizer

### The Ultimate Windows 11 Optimization Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://microsoft.com/powershell)

A comprehensive, all-in-one PowerShell utility to optimize, debloat, and maintain Windows 10 & 11. 
Designed for power users who want maximum performance and privacy with minimal effort, packaged into a single readable script.

## 🚀 Features at a Glance

This single script (`WinOptimizer.ps1`) includes **20 powerful tools**:

| Category | Features |
|---|---|
| **🛠 Optimization** | Startup Manager, RAM Optimizer, Network Repair, Services Tuning, Windows Update Manager |
| **🛡 Privacy** | Telemetry Shield, Location Tracking Disable, Advertising ID Kill |
| **🧹 Maintenance** | Deep Disk Clean, Bloatware Uninstaller (Junk/Popular Tiers), Software Auto-Updater |
| **📊 Diagnostics** | System Health Report, CPU/Disk Temperatures, Storage Analyzer, Battery Report |
| **✨ Safety** | Automatic System Restore, Windows Repair (DISM/SFC), VPN Protection |

## 📥 Installation

1. Download the latest release or clone this repo.
2. Unzip the folder to a safe location.

## ⚡ How to Run

### Method 1: The Easy Way (Recommended)
Double-click the included **`Run-Optimizer.bat`** file. 
(This automatically requests Admin privileges and bypasses execution policy restrictions).

### Method 2: PowerShell
Right-click **PowerShell** -> **Run as Administrator**, navigate to the folder, and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\WinOptimizer.ps1
```

## ⚠️ Requirements
- Windows 10 or Windows 11 (Home/Pro/Enterprise)
- PowerShell 5.1 or newer
- **Administrator Privileges** (Required for system changes)

## 🔒 Safety First
- **Restore Point**: The script prompts to create a System Restore Point before making changes.
- **Safe Fallbacks**: Critical services and drivers are whitelisted to prevent system instability.
- **Transparent**: The code is open-source. You can read exactly what it does.

## 📄 License
MIT License - Free to use, modify, and distribute.
