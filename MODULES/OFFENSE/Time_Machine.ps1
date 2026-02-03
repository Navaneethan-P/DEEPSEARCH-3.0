# =============================================================================
# FILE: Time_Machine.ps1
# MODULE: [4] TEMPORAL DRIFT DETECTOR (Encrypted)
# ARCHITECT: Navaneethan.P
# =============================================================================

param([string]$VaultPath)
$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   TIME MACHINE | CONFIGURATION DRIFT ENGINE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. CAPTURE CURRENT STATE (THE "NOW") ---
Write-Host "`n   [1/3] Scanning System DNA..." -ForegroundColor Yellow

$CurrentState = @{
    Date   = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    # Capture Local Administrators
    Admins = (Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | Select -Expand Name | Sort-Object)
    # Capture Open Listening Ports (Potential Backdoors)
    Ports  = (Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select -Expand LocalPort | Sort-Object -Unique)
    # Capture Installed Software Count (Rough check for stealth installs)
    Apps   = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).Count
}

# Convert to JSON for storage
$CurrentJson = $CurrentState | ConvertTo-Json -Depth 2
Write-Host "   [INFO] DNA Sequence Captured." -ForegroundColor Gray

# --- 2. COMPARE VS VAULT (THE "THEN") ---
Write-Host "`n   [2/3] Accessing Secure Vault..." -ForegroundColor Yellow

if (Test-Path $VaultPath) {
    # DECRYPT THE BASELINE
    $JsonRaw = Unprotect-Data -FilePath $VaultPath
    
    if ([string]::IsNullOrWhiteSpace($JsonRaw)) {
        Write-Host "   [ERROR] Vault Empty or Decryption Failed!" -ForegroundColor Red
        exit
    }

    $OldState = $JsonRaw | ConvertFrom-Json
    Write-Host "   [INFO] Baseline Loaded from: $($OldState.Date)" -ForegroundColor Green

    # --- CALCULATE DRIFT ---
    Write-Host "`n   [3/3] Calculating Temporal Drift..." -ForegroundColor Yellow
    $DriftDetected = $false

    # Check Admins
    $DiffAdmin = Compare-Object $OldState.Admins $CurrentState.Admins
    if ($DiffAdmin) { 
        Write-Host "   [!] CRITICAL ALERT: ADMIN GROUP CHANGED!" -ForegroundColor Red
        $DiffAdmin | ForEach-Object { Write-Host "       $($_.SideIndicator) $($_.InputObject)" -ForegroundColor Red }
        $DriftDetected = $true
    }

    # Check Ports
    $DiffPort = Compare-Object $OldState.Ports $CurrentState.Ports
    if ($DiffPort) { 
        Write-Host "   [!] NETWORK ALERT: OPEN PORTS CHANGED!" -ForegroundColor Red
        $DiffPort | ForEach-Object { Write-Host "       $($_.SideIndicator) Port $($_.InputObject)" -ForegroundColor Red }
        $DriftDetected = $true
    }

    if (-not $DriftDetected) {
        Write-Host "   [SECURE] No Configuration Drift Detected." -ForegroundColor Green
        Write-Host "            System is identical to the Baseline." -ForegroundColor Gray
    }

} else {
    # --- FIRST RUN INITIALIZATION ---
    Write-Host "   [NOTICE] No Baseline Found." -ForegroundColor Cyan
    Write-Host "   [ACTION] Creating First Secure Snapshot..." -ForegroundColor Yellow
    
    Protect-Data -PlainText $CurrentJson -FilePath $VaultPath
    Write-Host "   [SUCCESS] Baseline Encrypted & Saved to Vault." -ForegroundColor Green
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."