# Ultimate Windows Optimizer

A comprehensive, all-in-one PowerShell script to optimize, debloat, and maintain Windows 10 & 11. 
Designed for power users who want maximum performance and privacy with minimal effort.

## 🚀 Features

This single script (`cleanest.ps1`) includes **20 powerful tools**:

### 🛠 Optimization
1. **Optimize Startup**: Scan & disable bloatware startup apps (80+ known patterns).
2. **Optimize RAM**: Trim working sets of idle processes to free up memory.
3. **Deep Disk Clean**: Clear temp files, 12+ browser caches, Windows Update cache, and logs.
4. **Network Repair**: Flush DNS, reset TCP/IP stack, and optimize various network settings.
5. **Services Tuning**: Disable telemetry/tracking services and set safe manual triggers.
6. **Privacy Shield**: Disable telemetry, advertising ID, location tracking, and more.
7. **Windows Update Manager**: Pause updates, set active hours, or clear stuck update caches.

### 📊 Diagnostics
8. **System Health Report**: Detailed HTML/Text report of your PC's hardware and health.
9. **Quick Status**: Instant HUD for RAM, CPU, and heavy processes.
10. **Battery Health**: Generate a detailed battery report (cycles, capacity).
11. **Disk Health (S.M.A.R.T.)**: Monitor SSD/HDD health, temperature, and wear levels.
12. **Storage Analyzer**: Visualize what's taking up space on your drive.
13. **CPU Monitor**: Check real-time CPU packaging temperatures.

### 🧹 Cleaning & Bloatware
14. **Bloatware Uninstaller**: Remove pre-installed junk (Candy Crush, Xbox, trials) with a safe 2-tier system (Junk vs Popular).
15. **Software Updater**: Auto-update all your installed apps via Winget.
16. **Log Cleaner**: Remove old application logs to free space.

### 🛡 Safety & Maintenance
17. **System Restore**: One-click creation of Restore Points before any changes.
18. **Windows Repair**: Run DISM and SFC scans to fix corrupt Windows files.
19. **Restore Point Cleaner**: Delete old restore points to reclaim gigabytes of space.

## 📥 Installation

1. Download the latest release or clone this repo.
2. Unzip the folder to a safe location.

## ⚡ How to Run

### Method 1: The Easy Way (Recommended)
Double-click the included **`START.bat`** file. 
(This automatically requests Admin privileges and bypasses execution policy restrictions).

### Method 2: PowerShell
Right-click **PowerShell** -> **Run as Administrator**, then run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\cleanest.ps1
```

## ⚠️ Requirements
- Windows 10 or Windows 11
- PowerShell 5.1 or newer
- **Administrator Privileges** (Required for deep optimization)

## 🔒 Safety First
- **Restore Point**: The script prompts to create a System Restore Point before making changes.
- **Safe Fallbacks**: Critical services and drivers are whitelisted to prevent system instability.
- **Transparent**: The code is open-source and commented. You can see exactly what it does.

## 📄 License
MIT License - Free to use, modify, and distribute.
