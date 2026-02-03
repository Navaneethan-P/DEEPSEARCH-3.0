# =============================================================================
# FILE: Code_Hunter.ps1
# MODULE: [5] STATIC CODE ANALYSIS (Secret Scanner)
# ARCHITECT: Navaneethan.P
# =============================================================================

param([string]$TargetDir)
$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   CODE HUNTER | LEAKED SECRET SCANNER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# Default to C:\ drive if no input provided (warn user first)
if ([string]::IsNullOrWhiteSpace($TargetDir)) { 
    Write-Host "   [INFO] No path provided. Defaulting to User Desktop." -ForegroundColor Yellow
    $TargetDir = [Environment]::GetFolderPath("Desktop")
}

Write-Host "`n   [1/2] Indexing Files in: $TargetDir" -ForegroundColor Yellow

# --- DEFINE THREAT PATTERNS (Regex) ---
$Patterns = @{
    "AWS Access Key"      = "AKIA[0-9A-Z]{16}"
    "Google API Key"      = "AIza[0-9A-Za-z-_]{35}"
    "RSA Private Key"     = "-----BEGIN RSA PRIVATE KEY-----"
    "Generic API Token"   = "['`""]api_key['`""]\s*[:=]\s*['`""][a-zA-Z0-9_]{16,}['`""]"
    "Password Assignment" = "password\s*=\s*['`""][a-zA-Z0-9@#$%^&*]{6,}['`""]"
}

# --- SCANNING ENGINE ---
# We limit to text-based extensions to save time
$Extensions = @("*.txt", "*.py", "*.js", "*.json", "*.config", "*.xml", "*.ps1", "*.md")
$Files = Get-ChildItem -Path $TargetDir -Recurse -Include $Extensions -File -ErrorAction SilentlyContinue

$FoundSecrets = 0
Write-Host "   [2/2] Scanning Content..." -ForegroundColor Yellow

foreach ($File in $Files) {
    # Skip huge files (performance)
    if ($File.Length -gt 10MB) { continue }

    try {
        $Content = Get-Content $File.FullName -Raw
        
        foreach ($Key in $Patterns.Keys) {
            $Regex = $Patterns[$Key]
            if ($Content -match $Regex) {
                Write-Host "   [!] CRITICAL: $Key FOUND!" -ForegroundColor Red
                Write-Host "       File: $($File.Name)" -ForegroundColor White
                Write-Host "       Path: $($File.FullName)" -ForegroundColor DarkGray
                $FoundSecrets++
            }
        }
    } catch {}
}

# --- REPORT ---
Write-Host ""
if ($FoundSecrets -eq 0) {
    Write-Host "   [CLEAN] No leaked secrets found in scan target." -ForegroundColor Green
} else {
    Write-Host "   [ALERT] Scan finished. Found $FoundSecrets potential leaks." -ForegroundColor Red
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."