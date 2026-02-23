@echo off
setlocal
title WinOptimizer v4.0 - Loading...
color 0B



:: ============================================================
::  WinOptimizer Launcher
::  Author: Prakhar Aggarwal
::  GitHub: https://github.com/Prakhar0206/WinOptimizer
:: ============================================================

cls
echo.
echo   ========================================================
echo    WINOPTIMIZER - Ultimate Windows 10/11 Optimization Tool
echo   ========================================================
echo.

:: 1. Check if the PS1 file actually exists next to the BAT file
if not exist "%~dp0WinOptimizer.ps1" (
    color 0C
    echo   [ERROR] Could not find 'WinOptimizer.ps1'!
    echo   Make sure both files are in the exact same folder.
    echo.
    pause
    exit /b
)

:: 2. Check for admin rights
echo   Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Admin rights required. Requesting permission...
    echo.
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 3. Launch the script safely from its own directory
echo   Setting execution policy and launching...
cd /d "%~dp0"
echo.

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NoLogo -ExecutionPolicy Bypass -File "%~dp0WinOptimizer.ps1"

:: Pause only if the script crashes unexpectedly
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo   [ERROR] The script crashed or was closed unexpectedly.
    echo   Error Code: %errorlevel%
    pause
)
