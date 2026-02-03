@echo off
color 0a
cls
echo =========================================================
echo   DEEPSEARCH ARSENAL | FIRST TIME SETUP
echo =========================================================
echo.
echo   [1] Unblocking downloaded files...
powershell -Command "Get-ChildItem -Recurse | Unblock-File"

echo   [2] Setting Execution Policy...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force"

echo   [3] Creating Desktop Shortcut...
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Setup_Shortcut.ps1"

echo.
echo   [SUCCESS] System is Ready.
echo   You can now use the Desktop Shortcut or run Launch_Master.ps1
echo.
pause