@echo off
:: WinOptimizer Launcher
:: Use this if you cannot right-click > Run as Administrator on a .ps1 file directly.
:: It automatically requests elevation.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Admin permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
echo Starting WinOptimizer...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WinOptimizer.ps1"
pause
