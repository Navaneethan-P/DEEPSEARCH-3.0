# =============================================================================
# FILE: Vehicle_Recon.ps1
# MODULE: [OSINT] VEHICLE REGISTRATION INTELLIGENCE
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   VEHICLE RECON | TRANSPORT INTELLIGENCE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. INPUT ---
$Plate = Read-Host "   [?] ENTER VEHICLE NUMBER (e.g., TN07AB1234)"
if (-not $Plate) { exit }

# Clean Input (Remove spaces/hyphens)
$CleanPlate = $Plate -replace "[^a-zA-Z0-9]", ""
$StateCode = $CleanPlate.Substring(0,2).ToUpper()

Write-Host "`n   [ANALYZING] Plate: $CleanPlate" -ForegroundColor Yellow

# --- 2. DECODE REGION (India Context based on your location) ---
$States = @{
    "TN"="Tamil Nadu"; "KA"="Karnataka"; "KL"="Kerala"; "AP"="Andhra Pradesh";
    "DL"="Delhi"; "MH"="Maharashtra"; "UP"="Uttar Pradesh"; "WB"="West Bengal";
    "TS"="Telangana"; "PY"="Puducherry"
}

if ($States.ContainsKey($StateCode)) {
    Write-Host "   [REGION] $($States[$StateCode])" -ForegroundColor Green
} else {
    Write-Host "   [REGION] Unknown or Non-Standard State Code" -ForegroundColor Gray
}

# --- 3. INTELLIGENCE GATHERING ---
Write-Host "`n   [ACTION] Launching OSINT Search Protocols..." -ForegroundColor Cyan

# A. OFFICIAL REGISTRY (Parivahan)
Write-Host "   [1] Opening Official Registry..." -ForegroundColor Gray
Start-Process "https://vahan.parivahan.gov.in/nrservices/faces/user/citizen/citizenlogin.xhtml"

# B. CHALLAN SEARCH (Fine History)
Write-Host "   [2] Checking Traffic Violations (E-Challan)..." -ForegroundColor Gray
Start-Process "https://echallan.parivahan.gov.in/index/accused-challan"

# C. GOOGLE DORKS (News/Crime Reports)
Write-Host "   [3] Dorking News & Police Records..." -ForegroundColor Gray
$Query = "`"$CleanPlate`" OR `"$Plate`" AND (accident OR police OR challan OR owner)"
Start-Process "https://www.google.com/search?q=$Query"

Write-Host "`n   [INFO] Manual Captcha entry required on portals." -ForegroundColor Yellow
Read-Host "   Press Enter to return..."