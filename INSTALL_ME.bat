@echo off
color 0a
cls
echo =========================================================
echo   DEEPSEARCH ARSENAL | DIRECT LAUNCHER
echo =========================================================
echo.

:: 1. FORCE CURRENT DIRECTORY (Fixes "File Not Found" errors)
cd /d "%~dp0"

:: 2. UNBLOCK FILES (Silently fixes "Security Warning")
powershell -Command "Get-ChildItem -Recurse | Unblock-File" >nul 2>&1

:: 3. LAUNCH MASTER SCRIPT (With Error Catching)
echo   [INFO] Attempting to launch Kernel...
echo.

:: -NoExit forces the window to stay open so you can read errors
powershell -ExecutionPolicy Bypass -NoProfile -NoExit -File "Launch_Master.ps1"

echo.
echo =========================================================
echo   CRASH REPORT
echo =========================================================
echo   If the blue window above showed red text, copy it.
echo   If the blue window didn't appear at all, tell me.
echo.
pause