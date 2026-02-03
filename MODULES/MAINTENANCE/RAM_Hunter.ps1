# =============================================================================
# FILE: RAM_Hunter.ps1
# MODULE: [2] VOLATILE MEMORY FORENSICS
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   RAM HUNTER | LIVE PROCESS MEMORY SCANNER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- THREAT DATABASE (Signatures) ---
# In a real scenario, this list would be thousands of lines long.
$Signatures = @(
    "mimikatz",          # Password dumper
    "metasploit",        # Exploitation framework
    "meterpreter",       # Remote Access Trojan
    "powershell -enc",   # Encoded commands (often malicious)
    "downloadstring",    # Downloading malware from RAM
    "nc.exe",            # Netcat (Reverse shells)
    "xmrig"              # Crypto miner
)

Write-Host "`n   [1/2] Snapshotting Active Processes..." -ForegroundColor Yellow
$Processes = Get-Process
$Count = $Processes.Count
Write-Host "   [INFO] Scanned $Count active threads." -ForegroundColor Gray

Write-Host "`n   [2/2] Analyzing Command Line Arguments..." -ForegroundColor Yellow
$Suspicious = @()

# Loop through every running process
foreach ($Proc in $Processes) {
    # Use WMI to get the command line (Hidden from Task Manager)
    try {
        $WmiProc = Get-CimInstance Win32_Process -Filter "ProcessId = $($Proc.Id)"
        $CmdLine = $WmiProc.CommandLine
        
        if ($CmdLine) {
            foreach ($Sig in $Signatures) {
                if ($CmdLine -match $Sig) {
                    # THREAT DETECTED
                    $Suspicious += @{
                        PID = $Proc.Id
                        Name = $Proc.Name
                        Signature = $Sig
                        Command = $CmdLine
                    }
                    Write-Host "   [!] ALERT: MALICIOUS SIGNATURE FOUND!" -ForegroundColor Red
                    Write-Host "       PID:  $($Proc.Id)" -ForegroundColor White
                    Write-Host "       SIG:  $Sig" -ForegroundColor White
                }
            }
        }
    } catch {
        # Some system processes are protected and cannot be read. This is normal.
    }
}

# --- REPORTING ---
Write-Host ""
if ($Suspicious.Count -eq 0) {
    Write-Host "   [SECURE] No Memory Signatures Detected." -ForegroundColor Green
} else {
    Write-Host "   [WARNING] $($Suspicious.Count) THREATS IDENTIFIED." -ForegroundColor Red
    Write-Host "   Review the alerts above immediately." -ForegroundColor Gray
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."