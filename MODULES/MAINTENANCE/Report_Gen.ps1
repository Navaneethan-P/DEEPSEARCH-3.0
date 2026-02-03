# =============================================================================
# FILE: Report_Gen.ps1
# MODULE: [10] SYSTEM RECONNAISSANCE (SAFE MODE)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# --- 1. SETUP & DIRECTORY ---
$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BaseDir   = "$PSScriptRoot\..\REPORTS"
$ReportDir = "$BaseDir\Audit_$TimeStamp"

# Create Directory Structure
New-Item -Path $ReportDir -ItemType Directory -Force | Out-Null
New-Item -Path "$ReportDir\Windows_Defender" -ItemType Directory -Force | Out-Null

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   SYSTEM RECONNAISSANCE | DEEP AUDIT" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   [DESTINATION] $ReportDir" -ForegroundColor Gray
Write-Host ""

# --- HELPER FUNCTION TO PREVENT CRASHES ---
function Safe-Export {
    param($Cmd, $OutFile, $Name)
    Write-Host "   [.] Collecting $Name..." -NoNewline -ForegroundColor Yellow
    try {
        Invoke-Expression $Cmd | Out-File $OutFile -ErrorAction Stop
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " SKIPPED (Access Denied)" -ForegroundColor Red
        "ACCESS DENIED OR FAILED" | Out-File $OutFile
    }
}

# --- 2. SYSTEM INFORMATION ---
Write-Host "   [PHASE 1] SYSTEM & ENVIRONMENT" -ForegroundColor Cyan

# System Info (Can fail on some properties, so we select basic ones if full fails)
try {
    Get-ComputerInfo -ErrorAction Stop | Out-File "$ReportDir\system_info.txt"
    Write-Host "   [+] System Info: OK" -ForegroundColor Green
} catch {
    systeminfo | Out-File "$ReportDir\system_info.txt"
    Write-Host "   [+] System Info: OK (Fallback Mode)" -ForegroundColor Green
}

Get-ChildItem Env: | Out-File "$ReportDir\environment_variables.txt"

# .NET Versions
try {
    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | 
    Get-ItemProperty -Name Version -ErrorAction SilentlyContinue | 
    Select-Object PSChildName, Version | Out-File "$ReportDir\dotnet_versions.txt"
} catch {}

# Secure Boot (Known Crasher)
Safe-Export "Confirm-SecureBootUEFI" "$ReportDir\secure_boot_configuration.txt" "Secure Boot Status"

# Hotfixes
Safe-Export "Get-HotFix" "$ReportDir\installed_hotfixes.txt" "Hotfixes"

# --- 3. SECURITY CONFIGURATION ---
Write-Host "`n   [PHASE 2] SECURITY POLICIES" -ForegroundColor Cyan

# AMSI
Safe-Export "Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\AMSI\Providers' -Recurse" "$ReportDir\amsi_providers.txt" "AMSI Providers"

# Antivirus
Safe-Export "Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct" "$ReportDir\registered_antivirus.txt" "Antivirus"

# Audit Policy
Safe-Export "auditpol /get /category:*" "$ReportDir\audit_policy_settings.txt" "Audit Policies"

# UAC (Reg Export)
cmd /c "reg export HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System `"$ReportDir\uac_system_policies.reg`" /y" | Out-Null

# --- 4. NETWORK INTELLIGENCE ---
Write-Host "`n   [PHASE 3] NETWORK MAPPING" -ForegroundColor Cyan

Safe-Export "Get-NetAdapter" "$ReportDir\network_profiles.txt" "Network Adapters"
Safe-Export "Get-SmbShare" "$ReportDir\network_shares.txt" "SMB Shares"
Safe-Export "arp -a" "$ReportDir\arp_table.txt" "ARP Table"
Safe-Export "Get-DnsClientCache" "$ReportDir\dns_cache.txt" "DNS Cache"
Safe-Export "Get-NetTCPConnection" "$ReportDir\tcp_udp_connections.txt" "Active Connections"
Safe-Export "Get-NetFirewallRule" "$ReportDir\firewall_rules.txt" "Firewall Rules"

# --- 5. DEFENDER & MALWARE HUNTING ---
Write-Host "`n   [PHASE 4] DEFENDER & AUTO-RUNS" -ForegroundColor Cyan

Safe-Export "Get-MpPreference" "$ReportDir\Windows_Defender\windows_defender_settings.txt" "Defender Config"
Safe-Export "Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" "$ReportDir\auto_run_executables.txt" "Registry Auto-Runs"

# --- 6. USER ARTIFACTS ---
Write-Host "`n   [PHASE 5] USER ARTIFACTS" -ForegroundColor Cyan

Safe-Export "Get-LocalUser" "$ReportDir\local_users.txt" "Local Users"
Safe-Export "Get-LocalGroup" "$ReportDir\local_groups.txt" "Local Groups"

# PowerShell History
$HistoryPath = (Get-PSReadlineOption).HistorySavePath
if (Test-Path $HistoryPath) {
    Copy-Item $HistoryPath -Destination "$ReportDir\powershell_console_history.txt" -ErrorAction SilentlyContinue
}

# User Folders (Just list files, don't read content)
$UserPath = [Environment]::GetFolderPath("UserProfile")
Get-ChildItem "$UserPath\Desktop" -Name | Out-File "$ReportDir\user_folders_desktop.txt"
Get-ChildItem "$UserPath\Downloads" -Name | Out-File "$ReportDir\user_folders_downloads.txt"

# --- 7. COMPLETION ---
Write-Host ""
Write-Host "   [SUCCESS] RECONNAISSANCE COMPLETE." -ForegroundColor Green
Write-Host "   [INFO] Data exported to: $ReportDir" -ForegroundColor Gray
Write-Host ""

# Open the Folder
Invoke-Item $ReportDir

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."