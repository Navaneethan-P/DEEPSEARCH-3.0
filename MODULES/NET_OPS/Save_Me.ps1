# =============================================================================
# FILE: Save_Me.ps1
# MODULE: [9] EMERGENCY SYSTEM CLEANER
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   SAVE ME | ACTIVE DEFENSE PROTOCOL" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Red
Write-Host ""

# --- 1. KILLSWITCH (Terminate Hostile Processes) ---
Write-Host "   [1/4] Scanning for Hostile Processes..." -ForegroundColor Yellow
$BadList = @("xmrig", "minerd", "wannacry", "nc", "powershell_ise") # Add more as needed

foreach ($P in $BadList) {
    if (Get-Process -Name $P -ErrorAction SilentlyContinue) {
        Stop-Process -Name $P -Force
        Write-Host "   [KILL] Terminated: $P" -ForegroundColor Red
    }
}
Write-Host "   [OK] Process Scan Complete." -ForegroundColor Green

# --- 2. CLIPBOARD PURGE ---
Write-Host "`n   [2/4] Sanitizing Clipboard..." -ForegroundColor Yellow
try {
    # Using cmd pipe to wipe clipboard cleanly
    cmd /c "echo off | clip"
    Write-Host "   [SECURE] Clipboard Memory Wiped." -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Clipboard Access Denied." -ForegroundColor Red
}

# --- 3. NETWORK FLUSH ---
Write-Host "`n   [3/4] Flushing Network Artifacts..." -ForegroundColor Yellow
Clear-DnsClientCache
Write-Host "   [SECURE] DNS Cache Flushed." -ForegroundColor Green

# --- 4. DEBRIS REMOVAL ---
Write-Host "`n   [4/4] Purging Temp Files..." -ForegroundColor Yellow
$TempPath = [System.IO.Path]::GetTempPath()
$Items = Get-ChildItem -Path $TempPath -Recurse -ErrorAction SilentlyContinue
$Count = $Items.Count

if ($Count -gt 0) {
    Remove-Item "$TempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   [CLEAN] Removed $Count temporary files." -ForegroundColor Green
} else {
    Write-Host "   [CLEAN] Temp folder is already empty." -ForegroundColor Gray
}

Write-Host ""
Write-Host "   [SYSTEM] PROTOCOL COMPLETE. SYSTEM SANITIZED." -ForegroundColor Cyan
Write-Host ""
Read-Host "   Press Enter to return to Kernel..."