@echo off
color 0c
echo ==================================================
echo   DEEPSEARCH DEBUG LAUNCHER
echo ==================================================
echo.
echo Attempting to launch Kernel...
echo.

:: This command forces the window to stay open (-NoExit)
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File "CORE_ENGINE\DeepSearch_Kernel.ps1"

echo.
echo ==================================================
echo   CRASH REPORT
echo ==================================================
echo If you see red text above, copy it and send it to me.
echo If the script ran successfully, you can close this.
pause