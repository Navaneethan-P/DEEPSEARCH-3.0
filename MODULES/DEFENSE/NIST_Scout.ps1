# Security Score Auditor (NIST/CIS)
# =============================================================================
# FILE: NIST_Scout.ps1
# MODULE: [DEFENSE] SECURITY COMPLIANCE AUDITOR (NIST/CIS STANDARDS)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# --- UI HEADER ---
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   NIST SCOUT | SECURITY COMPLIANCE AUDITOR" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   [STANDARD] NIST SP 800-53 / CIS BENCHMARKS" -ForegroundColor DarkGray
Write-Host ""

$Score = 0
$TotalChecks = 0
$Issues = @()

function Run-Check ($Name, $Condition, $Points) {
    # Access the parent scope variables
    $Script:TotalChecks++
    
    Write-Host "   [TEST] $Name..." -NoNewline
    
    if ($Condition) {
        Write-Host " PASS" -ForegroundColor Green
        $Script:Score += $Points
    } else {
        Write-Host " FAIL" -ForegroundColor Red
        $Script:Issues += $Name
    }
    Start-Sleep -Milliseconds 100
}

# --- SECTION 1: ACCOUNT SECURITY ---
Write-Host "   [1] AUDITING ACCOUNT POLICIES" -ForegroundColor Yellow

# Check Guest Account (Should be Disabled)
$Guest = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
Run-Check "Guest Account Disabled" ($Guest.Enabled -eq $false) 10

# Check Administrator Account (Should be Renamed or Disabled - checking if active)
$Admin = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
Run-Check "Built-in Admin Disabled" ($Admin.Enabled -eq $false) 10

# Password Complexity (Requires Admin to read, simulated check via Registry)
# Checking if 'PasswordComplexity' flag is set in a common registry dump location or relying on policy
# We will check MinPasswordLength via net accounts text parsing (Legacy but works without AD module)
$NetAccounts = net accounts
$MinLen = $NetAccounts | Select-String "Minimum password length"
if ($MinLen -match "\d+") {
    $Len = [int]$matches[0]
    Run-Check "Min Password Length > 8" ($Len -ge 8) 5
} else {
    Run-Check "Password Policy Defined" ($false) 5
}

# --- SECTION 2: SYSTEM HARDENING ---
Write-Host "`n   [2] AUDITING SYSTEM HARDENING" -ForegroundColor Yellow

# UAC (User Account Control) - Prevents silent malware installs
$UAC = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA
Run-Check "UAC (User Account Control) Active" ($UAC.EnableLUA -eq 1) 15

# Remote Registry (Should be Disabled to prevent remote modification)
$RemReg = Get-Service "RemoteRegistry" -ErrorAction SilentlyContinue
Run-Check "Remote Registry Service Disabled" ($RemReg.Status -ne "Running") 5

# Windows Defender Real-Time Protection
$Def = Get-MpComputerStatus
Run-Check "Windows Defender Real-Time Protection" ($Def.RealTimeProtectionEnabled -eq $true) 15

# --- SECTION 3: NETWORK SECURITY ---
Write-Host "`n   [3] AUDITING NETWORK PERIMETER" -ForegroundColor Yellow

# Firewall Profiles
$FW = Get-NetFirewallProfile | Where-Object {$_.Enabled -eq $False}
Run-Check "Windows Firewall (All Profiles)" ($FW -eq $null) 10

# RDP (Remote Desktop) - Should be disabled or secured
$RDP = Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name fDenyTSConnections
Run-Check "RDP Connections Blocked" ($RDP.fDenyTSConnections -eq 1) 5

# SMBv1 (WannaCry Vulnerability) - Should be Disabled
$SMB1 = Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol
Run-Check "SMBv1 Protocol Disabled (Anti-WannaCry)" ($SMB1.EnableSMB1Protocol -eq $false) 10

# LLMNR (Link-Local Multicast Name Resolution) - Responder Attack Vector
# This is often not set by default.
$LLMNR = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name EnableMulticast -ErrorAction SilentlyContinue
Run-Check "LLMNR Disabled (Anti-Spoofing)" ($LLMNR.EnableMulticast -eq 0) 5

# --- SCORING ---
# Calculate Percentage
$MaxScore = 90 # Sum of points above
$FinalPercent = [math]::Round(($Script:Score / $MaxScore) * 100)

Write-Host "`n   ===================================================================" -ForegroundColor Cyan
if ($FinalPercent -ge 90) {
    Write-Host "   COMPLIANCE SCORE: $FinalPercent%" -ForegroundColor Green
    Write-Host "   RATING: EXCELLENT (NIST COMPLIANT)" -ForegroundColor Green
} elseif ($FinalPercent -ge 70) {
    Write-Host "   COMPLIANCE SCORE: $FinalPercent%" -ForegroundColor Yellow
    Write-Host "   RATING: ACCEPTABLE (MINOR RISKS)" -ForegroundColor Yellow
} else {
    Write-Host "   COMPLIANCE SCORE: $FinalPercent%" -ForegroundColor Red
    Write-Host "   RATING: CRITICAL VULNERABILITY DETECTED" -ForegroundColor Red
}
Write-Host "   ===================================================================" -ForegroundColor Cyan

if ($Issues.Count -gt 0) {
    Write-Host "`n   [!] RECOMMENDATIONS FOR HARDENING:" -ForegroundColor Red
    foreach ($Issue in $Issues) {
        Write-Host "    - FIX: $Issue" -ForegroundColor Gray
    }
} else {
    Write-Host "`n   [OK] SYSTEM IS FULLY HARDENED." -ForegroundColor Green
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."