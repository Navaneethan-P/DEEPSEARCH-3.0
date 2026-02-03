# =============================================================================
# FILE: Wifi_Radar.ps1
# MODULE: [7] WIRELESS SPECTRUM ANALYZER
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   WIFI RADAR | AIRSPACE SURVEILLANCE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n   [1/2] Scanning Wireless Interface..." -ForegroundColor Yellow

# Execute netsh
$RawData = netsh wlan show networks mode=bssid

if (-not $RawData) {
    Write-Host "   [ERROR] No Wireless Interface Found or Wifi is Off." -ForegroundColor Red
    Write-Host "   [HINT]  Ensure Windows 'Location Services' are ON." -ForegroundColor DarkGray
    Read-Host "   Press Enter to return..."
    exit
}

Write-Host "   [2/2] Parsing Signal Telemetry..." -ForegroundColor Yellow
Write-Host ""

$Header = "{0,-30} {1,-10} {2,-15} {3}" -f "SSID (NAME)", "SIGNAL", "AUTH", "STATUS"
Write-Host "   $Header" -ForegroundColor White
Write-Host "   --------------------------------------------------------------------------" -ForegroundColor DarkGray

# Temp storage
$CurrentSSID = ""
$CurrentSignal = ""
$CurrentAuth = ""

foreach ($Line in $RawData) {
    $Line = $Line.Trim()
    
    # 1. Match SSID
    if ($Line -match "^SSID") {
        $Parts = $Line -split ":"
        if ($Parts.Count -ge 2) { $CurrentSSID = $Parts[1].Trim() }
    }
    
    # 2. Match Authentication
    elseif ($Line -match "^Authentication") {
        $Parts = $Line -split ":"
        if ($Parts.Count -ge 2) { $CurrentAuth = $Parts[1].Trim() }
    }
    
    # 3. Match Signal
    elseif ($Line -match "^Signal") {
        $Parts = $Line -split ":"
        if ($Parts.Count -ge 2) { $CurrentSignal = $Parts[1].Trim() }
        
        # We now have a full set of data. Print it.
        if ($CurrentSSID -ne "") {
            
            # Security Check
            if ($CurrentAuth -match "Open") {
                $StatusColor = "Red"
                $StatusText = "UNSECURE"
            } else {
                $StatusColor = "Green"
                $StatusText = "SECURE"
            }
            
            # Print Row
            $Row = "{0,-30} {1,-10} {2,-15} " -f $CurrentSSID, $CurrentSignal, $CurrentAuth
            Write-Host "   $Row" -NoNewline
            Write-Host "$StatusText" -ForegroundColor $StatusColor
        }
        
        # Reset for next network
        $CurrentSSID = ""
    }
}

Write-Host ""
Write-Host "   [SYSTEM] SCAN COMPLETE." -ForegroundColor Gray
Write-Host ""
Read-Host "   Press Enter to return to Kernel..."