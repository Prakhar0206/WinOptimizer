@echo off
:: Ultimate Laptop Optimizer v3.2 - Launcher
:: Right-click > Run as Administrator (or this will auto-elevate)

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Run the optimizer
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0cleanest.ps1"
pause
