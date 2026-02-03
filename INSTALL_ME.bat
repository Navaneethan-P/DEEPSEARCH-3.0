@echo off
color 0a
cls
echo =========================================================
echo   DEEPSEARCH ARSENAL | UNIVERSAL INSTALLER
echo =========================================================
echo.

:: 1. UNBLOCK FILES (Fixes "Security Warning" on new laptops)
echo   [1/3] Unblocking System Files...
powershell -Command "Get-ChildItem -Recurse | Unblock-File" >nul 2>&1

:: 2. SET EXECUTION POLICY (Fixes "Script Disabled" error)
echo   [2/3] Authorizing PowerShell Scripts...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force" >nul 2>&1

:: 3. CREATE SHORTCUT (Embedded Generator)
echo   [3/3] Creating Desktop Shortcut...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"

echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = oWS.ExpandEnvironmentStrings("%%USERPROFILE%%\Desktop\DEEPSEARCH ARSENAL.lnk") >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%~dp0Launch_Master.ps1" >> %SCRIPT%
echo oLink.IconLocation = "C:\Windows\System32\SHELL32.dll, 13" >> %SCRIPT%
echo oLink.Description = "Launch Zero Trust Kernel" >> %SCRIPT%
echo oLink.WorkingDirectory = "%~dp0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

echo.
echo =========================================================
echo   [SUCCESS] INSTALLATION COMPLETE
echo =========================================================
echo.
echo   1. A shortcut has been created on your Desktop.
echo   2. You can also run 'Launch_Master.ps1' directly.
echo.
pause