# Canary File Trap & Process Killer
# =============================================================================
# FILE: Ransomware_Shield.ps1
# MODULE: [DEFENSE] HEURISTIC TRIPWIRE (CANARY TRAP)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   RANSOMWARE SHIELD | HEURISTIC TRIPWIRE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Red

# --- 1. SETUP TRAP ---
$TargetDir = [Environment]::GetFolderPath("MyDocuments")
$CanaryFile = "$TargetDir\_DEEPSEARCH_CANARY_DO_NOT_TOUCH.txt"

# Create the Bait File if missing
if (-not (Test-Path $CanaryFile)) {
    Set-Content -Path $CanaryFile -Value "This is a honeypot file. Any modification triggers a security alert." -Force
    # Hide the file (make it a system file so user doesn't delete it accidentally)
    $Item = Get-Item -Path $CanaryFile
    $Item.Attributes = "Hidden"
}

Write-Host "   [1/3] ARMING TRIPWIRE..." -ForegroundColor Yellow
Write-Host "   [LOC] $CanaryFile" -ForegroundColor DarkGray
Write-Host "   [STATUS] Monitoring file system events..." -ForegroundColor Green

# --- 2. DEFINE ACTION BLOCK ---
$Action = {
    Write-Host "`n   [!!!] CRITICAL ALERT: RANSOMWARE ACTIVITY DETECTED [!!!]" -ForegroundColor Red -BackgroundColor Black
    Write-Host "   [EVENT] The Canary File was modified or deleted." -ForegroundColor Red
    Write-Host "   [TIME] $(Get-Date)" -ForegroundColor Yellow
    Write-Host "   [ACTION] CHECK YOUR PROCESSES IMMEDIATELY!" -ForegroundColor Yellow
    
    # Sound Alarm (System Beep)
    [Console]::Beep(1000, 500)
    [Console]::Beep(1500, 500)
    [Console]::Beep(1000, 500)
    
    # Log the breach
    $LogPath = "$HOME\Desktop\DEEPSEARCH_ZEROTRUST\DATA\security_events.log"
    "$(Get-Date) | RANSOMWARE TRIPWIRE TRIGGERED | File: $Event.SourceEventArgs.FullPath" | Out-File $LogPath -Append
}

# --- 3. REGISTER WATCHERS ---
# We use System.IO.FileSystemWatcher for real-time monitoring
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $TargetDir
$Watcher.Filter = "_DEEPSEARCH_CANARY_DO_NOT_TOUCH.txt"
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true

# Bind Events
Register-ObjectEvent $Watcher "Changed" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Deleted" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Renamed" -Action $Action | Out-Null

Write-Host "   [2/3] SHIELD ACTIVE." -ForegroundColor Green
Write-Host "   [INFO] Minimize this window. Do not close it." -ForegroundColor Gray
Write-Host "   [INFO] To test: Go to Documents and try to delete the hidden file." -ForegroundColor Gray
Write-Host ""
Write-Host "   [RUNNING] Press Enter to Disarm and Exit..." -ForegroundColor Cyan

# Keep script running until user hits Enter
Read-Host

# --- 4. CLEANUP ---
Unregister-Event -SourceIdentifier "Changed" -ErrorAction SilentlyContinue
Unregister-Event -SourceIdentifier "Deleted" -ErrorAction SilentlyContinue
Unregister-Event -SourceIdentifier "Renamed" -ErrorAction SilentlyContinue
$Watcher.EnableRaisingEvents = $false
$Watcher.Dispose()

Write-Host "   [DISARMED] Shield Deactivated." -ForegroundColor Yellow
Start-Sleep -Seconds 1