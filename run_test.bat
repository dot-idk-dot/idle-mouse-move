@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

echo ========================================
echo   Mouse Auto-Move Test
echo ========================================
echo.
echo Running test script...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_test.ps1"

echo.
echo Test completed. Check mouse_log.txt for details.
echo.
pause
