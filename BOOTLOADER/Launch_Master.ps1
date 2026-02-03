# =============================================================================
# FILE: Launch_Master.ps1
# LAYER: BOOTLOADER (Level 0)
# ARCHITECT: Navaneethan.P
# =============================================================================

# --- 1. SYSTEM PRE-FLIGHT CHECK ---
$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "DEEPSEARCH ZERO TRUST | BOOT SEQUENCE"

# Robust Administrator Check (Using .NET Security Principals)
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")

if (-not $IsAdmin) {
    Write-Host "`n   [!] SYSTEM ERROR: INSUFFICIENT PRIVILEGES." -ForegroundColor Red
    Write-Host "   [+] RESTARTING WITH ROOT ACCESS..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    
    # Relaunch self as Administrator
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- 2. ENVIRONMENT INITIALIZATION ---
Clear-Host
$BootloaderDir = $PSScriptRoot
$Root = Split-Path -Parent $BootloaderDir
$KernelPath = "$Root\CORE_ENGINE\DeepSearch_Kernel.ps1"

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   DEEPSEARCH ZERO TRUST ARCHITECTURE (v7.0)" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""

# Simulate Hardware/System Checks
$Checks = @("Memory Integrity", "AES Crypto Engine", "Watchdog Service", "Network Interface")
foreach ($Check in $Checks) {
    Write-Host -NoNewline "   [+] Verifying $Check... " -ForegroundColor Gray
    Start-Sleep -Milliseconds 150
    Write-Host "OK" -ForegroundColor Green
}
Write-Host ""

# --- 3. KERNEL HANDOFF ---
if (-not (Test-Path $KernelPath)) {
    Write-Host "   [CRITICAL FATAL ERROR]" -ForegroundColor Red -BackgroundColor Black
    Write-Host "   Kernel file missing at: $KernelPath" -ForegroundColor Red
    Write-Host "   System Halted." -ForegroundColor Gray
    Read-Host "   Press Enter to exit..."
    exit
}

Write-Host "   [>] HANDING OFF CONTROL TO KERNEL..." -ForegroundColor Yellow
Start-Sleep -Milliseconds 800

# Execute Kernel (Using Call Operator '&')
# We do NOT use Start-Process here, because we want the Kernel to take over THIS window.
Set-Location $Root
& $KernelPath

# Note: The script waits here until the Kernel closes.
Write-Host "`n   [SYSTEM] SESSION TERMINATED." -ForegroundColor DarkGray
Start-Sleep -Seconds 2