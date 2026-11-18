@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo ========================================
echo   Mouse Auto-Move Script
echo ========================================
echo.
echo This script will:
echo - Move mouse left 50px every 5 seconds
echo - Move mouse right 50px every 5 seconds
echo - Keep screen awake
echo.
echo Press Ctrl+C to stop or close this window
echo ========================================
echo.
pause

echo.
echo Starting mouse movement...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0mouse_move.ps1"

echo.
echo Mouse movement stopped.
echo.
pause
