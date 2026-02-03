# =============================================================================
# FILE: Ghost_Protocol.ps1
# MODULE: [6] ARTIFACT DUMPER (Digital Residue)
# ARCHITECT: Navaneethan.P
# =============================================================================

# Add Type for Clipboard Access
Add-Type -AssemblyName System.Windows.Forms
$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   GHOST PROTOCOL | FORENSIC ARTIFACT DUMPER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. CLIPBOARD ANALYSIS ---
Write-Host "`n   [1/3] Dumping Clipboard Buffer..." -ForegroundColor Yellow
try {
    # We must run this in a Single Threaded Apartment (STA) mode usually, 
    # but here we try direct access.
    if ([System.Windows.Forms.Clipboard]::ContainsText()) {
        $Clip = [System.Windows.Forms.Clipboard]::GetText()
        if ($Clip.Length -gt 100) { $Clip = $Clip.Substring(0, 100) + "..." }
        Write-Host "   [DATA FOUND] '$Clip'" -ForegroundColor Red
    } else {
        Write-Host "   [CLEAN] Clipboard is empty or contains non-text data." -ForegroundColor Green
    }
} catch {
    Write-Host "   [ERROR] Could not access Clipboard (Access Denied)." -ForegroundColor Gray
}

# --- 2. POWERSHELL HISTORY ---
Write-Host "`n   [2/3] Extracting Command History (Last 5)..." -ForegroundColor Yellow
$HistPath = (Get-PSReadlineOption).HistorySavePath

if (Test-Path $HistPath) {
    Write-Host "   [SOURCE] $HistPath" -ForegroundColor DarkGray
    $History = Get-Content $HistPath -Tail 5
    foreach ($Line in $History) {
        Write-Host "   > $Line" -ForegroundColor White
    }
} else {
    Write-Host "   [INFO] No History File Found." -ForegroundColor Gray
}

# --- 3. ARP CACHE (Network Ghosts) ---
Write-Host "`n   [3/3] Scanning ARP Cache (Recent Connections)..." -ForegroundColor Yellow
$ARP = arp -a
if ($ARP) {
    # Extract just the dynamic entries usually found at the bottom
    $ARP | Select-Object -Last 5 | ForEach-Object {
        if (-not [string]::IsNullOrWhiteSpace($_)) {
            Write-Host "   $_" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "   [SYSTEM] ARTIFACT COLLECTION COMPLETE." -ForegroundColor Green
Write-Host ""
Read-Host "   Press Enter to return to Kernel..."