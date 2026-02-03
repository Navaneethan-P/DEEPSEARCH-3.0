# =============================================================================
# FILE: Active_Deception.ps1
# MODULE: [1] HONEY-TOKEN TRAP
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# --- CONFIGURATION ---
# We use the User's Documents folder as the trap site
$TrapDir = "$env:USERPROFILE\Documents\Critical_Backup"
$HoneyTokens = @("passwords.txt", "bitcoin_wallet.dat", "employee_salaries.xlsx")

# --- 1. DEPLOYMENT PHASE ---
Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   ACTIVE DECEPTION SYSTEM | HONEYPOT DEPLOYMENT" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Red

Write-Host "`n   [1/2] Planting Decoy Files..." -ForegroundColor Cyan

# Create Directory if missing
if (-not (Test-Path $TrapDir)) {
    New-Item -ItemType Directory -Force -Path $TrapDir | Out-Null
}

# Create Fake Files
foreach ($File in $HoneyTokens) {
    $Path = "$TrapDir\$File"
    if (-not (Test-Path $Path)) {
        Set-Content -Path $Path -Value "WARNING: THIS IS A DECOY FILE. DO NOT TOUCH. ALARM TRIGGERED."
        Write-Host "   [+] Trap Set: $File" -ForegroundColor Green
    } else {
        Write-Host "   [.] Trap Exists: $File" -ForegroundColor DarkGray
    }
}

# Auto-open folder for verification
Write-Host "   [INFO] Trap Location: $TrapDir" -ForegroundColor Yellow
Invoke-Item $TrapDir

# --- 2. SURVEILLANCE PHASE ---
Write-Host "`n   [2/2] Arming Sensors (Press Ctrl+C to Stop)..." -ForegroundColor Yellow
Write-Host "   [SYSTEM] WATCHING FOR FILE ACCESS..." -ForegroundColor Green

# Create the Watcher
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $TrapDir
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# Define the Alarm Action
$Action = {
    $Path = $Event.SourceEventArgs.FullPath
    $ChangeType = $Event.SourceEventArgs.ChangeType
    
    # VISUAL & AUDIO ALARM
    Write-Host ""
    Write-Host "   [ALARM] TRIPWIRE TRIGGERED!" -ForegroundColor White -BackgroundColor Red
    Write-Host "   [INFO] Intruder Touched: $Path" -ForegroundColor Red
    Write-Host "   [INFO] Action Type:      $ChangeType" -ForegroundColor Red
    Write-Host "   [LOG] Incident Recorded to Blackbox." -ForegroundColor Gray
    
    # Beep Pattern (High-Low-High)
    [Console]::Beep(1000, 200)
    [Console]::Beep(500, 200)
    [Console]::Beep(1000, 200)
}

# Register Events
Register-ObjectEvent $Watcher "Changed" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Deleted" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Renamed" -Action $Action | Out-Null

# Keep the script running forever
while ($true) { Start-Sleep -Seconds 1 }