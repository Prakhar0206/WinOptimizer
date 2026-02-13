@echo off
setlocal
title WinOptimizer v3.3 - Loading...
color 0B

:: ============================================================
::  WinOptimizer Launcher
::  Author: Prakhar Aggarwal
::  GitHub: https://github.com/Prakhar0206/WinOptimizer
:: ============================================================

cls
echo.
echo   ========================================================
echo    WINOPTIMIZER - Ultimate Windows 11 Optimization Tool
echo   ========================================================
echo.
echo   Checking Administrator privileges...

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [!] Admin rights required. Requesting permission...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set execution policy for the current process scope only (safe)
echo   Setting execution policy...
cd /d "%~dp0"

:: Launch the script
echo   Launching WinOptimizer...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0WinOptimizer.ps1"

:: Pause only if the script crashes unexpectedly
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo   [ERROR] The script crashed or was closed unexpectedly.
    echo   Error Code: %errorlevel%
    pause
)
