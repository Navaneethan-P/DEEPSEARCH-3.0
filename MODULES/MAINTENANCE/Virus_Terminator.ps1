# =============================================================================
# FILE: Virus_Terminator.ps1
# MODULE: [MAINTENANCE] TARGETED MALWARE REMOVAL
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   VIRUS TERMINATOR | FORENSIC CLEANER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Red

# --- 1. SELECT TARGET ---
Write-Host "   [TARGET SELECTION]" -ForegroundColor Yellow
Write-Host "   [1] SYSTEM DRIVE (C:)" -ForegroundColor White
Write-Host "   [2] SPECIFIC FOLDER" -ForegroundColor White
Write-Host "   [3] USB / EXTERNAL DRIVE" -ForegroundColor White
Write-Host ""
$Choice = Read-Host "   root@cleaner:~# Select Target"

$ScanPath = ""

if ($Choice -eq "1") {
    $ScanPath = "C:\"
}
elseif ($Choice -eq "2") {
    # Use file dialog for ease
    Add-Type -AssemblyName System.Windows.Forms
    $Folder = New-Object System.Windows.Forms.FolderBrowserDialog
    $Folder.Description = "Select Folder to Decontaminate"
    if ($Folder.ShowDialog() -eq "OK") { $ScanPath = $Folder.SelectedPath }
}
elseif ($Choice -eq "3") {
    # List Drives
    $Drives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -ne "C:\"}
    Write-Host "`n   [AVAILABLE DRIVES]" -ForegroundColor Cyan
    foreach ($D in $Drives) { Write-Host "   [$($D.Name)] $($D.Description)" }
    $Letter = Read-Host "   Enter Drive Letter (e.g., E)"
    $ScanPath = "$Letter`:\"
}

if (-not $ScanPath) { Write-Host "   [ABORT] No target selected."; exit }

# --- 2. EXECUTE DEFENDER SCAN ---
Write-Host "`n   [ENGAGING] Windows Defender Forensic Engine..." -ForegroundColor Yellow
Write-Host "   [TARGET] $ScanPath" -ForegroundColor Cyan

# Start-MpScan is the built-in PowerShell command for Defender
try {
    Start-MpScan -ScanType CustomScan -ScanPath $ScanPath -ErrorAction Stop
    Write-Host "   [SUCCESS] Scan Complete. Threats neutralized by Defender." -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Defender failed to start. Ensure you are Administrator." -ForegroundColor Red
}

# --- 3. USB SPECIFIC CLEANUP (Unhide Files) ---
if ($Choice -eq "3") {
    Write-Host "`n   [USB OPS] Attempting to fix 'Hidden File' Virus artifact..." -ForegroundColor Yellow
    
    # 1. Remove Autorun.inf (Common virus starter)
    $Autorun = "$ScanPath\autorun.inf"
    if (Test-Path $Autorun) {
        Remove-Item -Path $Autorun -Force -ErrorAction SilentlyContinue
        Write-Host "   [KILL] Deleted suspicious 'autorun.inf'" -ForegroundColor Green
    }

    # 2. Unhide all files (attrib -h -r -s)
    Write-Host "   [RECOVER] Unhiding data..." -ForegroundColor Gray
    cmd /c "attrib -h -r -s /s /d $ScanPath\*.*"
    
    Write-Host "   [DONE] USB Files should be visible now." -ForegroundColor Green
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."