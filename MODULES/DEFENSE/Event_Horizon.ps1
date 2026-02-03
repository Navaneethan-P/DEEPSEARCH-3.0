# =============================================================================
# FILE: Event_Horizon.ps1
# MODULE: [8] BRUTE FORCE ANALYZER
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   EVENT HORIZON | SECURITY LOG ANALYZER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n   [1/2] Querying Security Event Log (Last 24 Hours)..." -ForegroundColor Yellow

# Get Failed Logins (ID 4625)
$Events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625; StartTime=(Get-Date).AddDays(-1)} -ErrorAction SilentlyContinue

if (-not $Events) {
    Write-Host ""
    Write-Host "   [CLEAN] No Failed Login Attempts found in the last 24h." -ForegroundColor Green
    Write-Host ""
    Read-Host "   Press Enter to return..."
    exit
}

$Count = $Events.Count
Write-Host "   [!] WARNING: FOUND $Count FAILED LOGIN ATTEMPTS!" -ForegroundColor Red

Write-Host "`n   [2/2] Analyzing Attack Vectors..." -ForegroundColor Yellow

# Group by User Account
Write-Host "`n   --- TOP TARGETED ACCOUNTS ---" -ForegroundColor Cyan
$Events | Group-Object @{Expression={$_.Properties[5].Value}} | Sort-Object Count -Descending | Select-Object Count, Name | Format-Table -AutoSize

# Group by IP Address
Write-Host "   --- TOP ATTACKING IP ADDRESSES ---" -ForegroundColor Cyan
$Events | Group-Object @{Expression={$_.Properties[19].Value}} | Sort-Object Count -Descending | Select-Object Count, Name | Format-Table -AutoSize

Write-Host ""
Write-Host "   [ANALYSIS COMPLETE]" -ForegroundColor Gray
Read-Host "   Press Enter to return..."