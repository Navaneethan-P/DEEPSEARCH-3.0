# =============================================================================
# FILE: Watchdog.ps1
# ROLE: BODYGUARD (X-RAY VISION MODE)
# =============================================================================

# We look for the FILE NAME in the command line, not the Window Title.
$TargetScript = "DeepSearch_Kernel.ps1"
$KernelPath = "$PSScriptRoot\$TargetScript"

[Console]::Title = "DEEPSEARCH | WATCHDOG"
Write-Host "[+] WATCHDOG SERVICE ACTIVE." -ForegroundColor Green

while ($true) {
    # 1. SCAN ALL PROCESSES (Using WMI to see the full command line)
    # We ask Windows: "Show me any PowerShell process running 'DeepSearch_Kernel.ps1'"
    $IsRunning = Get-CimInstance Win32_Process -Filter "Name = 'powershell.exe'" | 
                 Where-Object { $_.CommandLine -match $TargetScript }

    if ($IsRunning) {
        # BODYGUARD SAYS: "I see the boss. He is safe."
        # We write nothing to keep the screen clean, just a dot.
        Write-Host "." -NoNewline -ForegroundColor DarkGray
    } 
    else {
        # BODYGUARD SAYS: "THE BOSS IS GONE! RESPAWNING!"
        Write-Host ""
        Write-Host "   [!] ALERT: KERNEL DEAD. REVIVING..." -ForegroundColor Red
        
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$KernelPath`""
        
        Write-Host "   [+] RECOVERY INITIATED." -ForegroundColor Yellow
        
        # Wait 5 seconds for the new one to start
        Start-Sleep -Seconds 5
    }
    
    # Check every 3 seconds
    Start-Sleep -Seconds 3
}