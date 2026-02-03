# =============================================================================
# FILE: Phone_Recon.ps1
# MODULE: [OSINT] PHONE NUMBER INTELLIGENCE
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   PHONE RECON | DIGITAL FOOTPRINT SCANNER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. INPUT ---
$Number = Read-Host "   [?] ENTER PHONE NUMBER (e.g., 9876543210)"
if (-not $Number) { exit }

# Clean Input
$CleanNum = $Number -replace "[^0-9]", ""

# Basic India Validation (Adjust if you need International)
if ($CleanNum.Length -eq 10) { 
    $CountryCode = "91" 
    $FullNum = "$CountryCode$CleanNum"
} 
elseif ($CleanNum.Length -gt 10) {
    $FullNum = $CleanNum
} 
else {
    Write-Host "   [ERROR] Invalid Number Length." -ForegroundColor Red
    exit
}

Write-Host "`n   [TARGET LOCKED] +$FullNum" -ForegroundColor Yellow
Write-Host "   [ACTION] Enumerating digital presence..." -ForegroundColor Gray
Write-Host ""

# --- 2. WHATSAPP RECON (Profile Photo Hack) ---
Write-Host "   [1] WhatsApp Profile Scan" -ForegroundColor Green
Write-Host "       -> Opening direct API link. Look for Profile Photo." -ForegroundColor Gray
Start-Process "https://web.whatsapp.com/send?phone=$FullNum"
Start-Sleep -Seconds 2

# --- 3. TRUECALLER (Name ID) ---
Write-Host "`n   [2] TrueCaller Database Search" -ForegroundColor Green
Write-Host "       -> Querying global directory..." -ForegroundColor Gray
Start-Process "https://www.truecaller.com/search/in/$CleanNum"
Start-Sleep -Seconds 1

# --- 4. GOOGLE DORKS (Public Records) ---
Write-Host "`n   [3] Google Dorking (Files & PDFs)" -ForegroundColor Green
Write-Host "       -> Searching for phone number in public documents..." -ForegroundColor Gray
$Query = "`"%2B$CountryCode $CleanNum`" OR `"$CleanNum`" AND (filetype:pdf OR filetype:xls OR site:facebook.com OR site:instagram.com)"
Start-Process "https://www.google.com/search?q=$Query"

# --- 5. UPI / PAYMENT APPS (Legal Name Check) ---
Write-Host "`n   [4] UPI / Payment Verification" -ForegroundColor Green
Write-Host "       -> Manual Check: Open GPay/PhonePe and try to send Rs.1" -ForegroundColor Yellow
Write-Host "       -> This usually reveals the FULL LEGAL BANK NAME." -ForegroundColor White

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   [INFO] Scans launched in browser." -ForegroundColor Gray
Read-Host "   Press Enter to return to Kernel..."