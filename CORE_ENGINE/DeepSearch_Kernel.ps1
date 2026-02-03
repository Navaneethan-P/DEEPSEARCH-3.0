# =============================================================================
# FILE: DeepSearch_Kernel.ps1
# LAYER: CORE ENGINE (v8.1 FINAL)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "Stop"
[Console]::Title = "DEEPSEARCH ZERO TRUST | KERNEL HYPERVISOR v8.1"

try {
    # --- 1. CONFIGURATION ---
    $CorePath = $PSScriptRoot
    $Root = Split-Path -Parent $CorePath
    $ModulesDir = "$Root\MODULES"
    
    # --- 2. ENCRYPTION CHECK ---
    $CryptEngine = "$ModulesDir\MAINTENANCE\AES_Crypt.ps1"
    if (Test-Path $CryptEngine) {
        try { . $CryptEngine; $CryptStatus = "ACTIVE"; $CryptColor = "Green" } 
        catch { $CryptStatus = "ERROR"; $CryptColor = "Red" }
    } else { $CryptStatus = "MISSING"; $CryptColor = "Red" }

    # --- 3. UI ENGINE ---
    function Draw-Header {
        Clear-Host
        # CLEAN BLOCK FONT BANNER
        Write-Host "  ____  _____ _____ ____  ____  _____    _    ____   ____ _   _ " -ForegroundColor Cyan
        Write-Host " |  _ \| ____| ____|  _ \/ ___|| ____|  / \  |  _ \ / ___| | | |" -ForegroundColor Cyan
        Write-Host " | | | |  _| |  _| | |_) \___ \|  _|   / _ \ | |_) | |   | |_| |" -ForegroundColor White
        Write-Host " | |_| | |___| |___|  __/ ___) | |___ / ___ \|  _ <| |___|  _  |" -ForegroundColor Cyan
        Write-Host " |____/|_____|_____|_|   |____/|_____/_/   \_\_| \_\\____|_| |_|" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "       ZERO TRUST ARSENAL | v8.1 | USER: $env:USERNAME   " -ForegroundColor DarkGray
        Write-Host "=================================================================" -ForegroundColor Cyan
    }

    function Get-ToolCount ($SubFolder) {
        $Path = "$ModulesDir\$SubFolder"
        if (Test-Path $Path) { return (Get-ChildItem $Path -Filter *.ps1).Count }
        return 0
    }

    # --- 4. MAIN MENU ---
    function Show-MainMenu {
        Draw-Header
        Write-Host "   [ SYSTEM STATUS ]" -ForegroundColor Yellow
        Write-Host "   KERNEL:   " -NoNewline; Write-Host "ONLINE" -ForegroundColor Green
        Write-Host "   VAULT:    " -NoNewline; Write-Host $CryptStatus -ForegroundColor $CryptColor
        Write-Host ""
        
        Write-Host "   [ OPERATIONAL DIVISIONS ]" -ForegroundColor Cyan
        
        $C1 = Get-ToolCount "OSINT";       Write-Host "   [1] OSINT INTELLIGENCE  " -NoNewline; Write-Host "($C1 Tools)" -ForegroundColor DarkGray
        $C2 = Get-ToolCount "DEFENSE";     Write-Host "   [2] ACTIVE DEFENSE      " -NoNewline; Write-Host "($C2 Tools)" -ForegroundColor DarkGray
        $C3 = Get-ToolCount "OFFENSE";     Write-Host "   [3] RED TEAM ARSENAL    " -NoNewline; Write-Host "($C3 Tools)" -ForegroundColor DarkGray
        $C4 = Get-ToolCount "NET_OPS";     Write-Host "   [4] NETWORK OPERATIONS  " -NoNewline; Write-Host "($C4 Tools)" -ForegroundColor DarkGray
        $C5 = Get-ToolCount "MAINTENANCE"; Write-Host "   [5] SYSTEM MAINTENANCE  " -NoNewline; Write-Host "($C5 Tools)" -ForegroundColor DarkGray
        
        Write-Host ""
        Write-Host "   [0] SHUTDOWN" -ForegroundColor DarkGray
        Write-Host "=================================================================" -ForegroundColor Cyan
    }

    # --- 5. SUB-MENU ENGINE ---
    function Show-SubMenu ($Category) {
        while ($true) {
            Draw-Header
            Write-Host "   [ DIVISION: $Category ]" -ForegroundColor Yellow
            Write-Host ""
            
            $TargetFolder = "$ModulesDir\$Category"
            if (-not (Test-Path $TargetFolder)) {
                Write-Host "   [ERROR] Folder '$Category' not found!" -ForegroundColor Red; Read-Host "   Press Enter..."; break
            }

            $Tools = Get-ChildItem $TargetFolder -Filter *.ps1
            $Index = 1
            $ToolMap = @{}

            if ($Tools.Count -eq 0) { Write-Host "   [EMPTY] No tools installed." -ForegroundColor Gray } 
            else {
                foreach ($Tool in $Tools) {
                    $CleanName = $Tool.BaseName -replace "_", " "
                    Write-Host "   [$Index] $CleanName" -ForegroundColor White
                    $ToolMap[$Index] = $Tool.FullName
                    $Index++
                }
            }
            
            Write-Host ""
            Write-Host "   [B] BACK TO MAIN MENU" -ForegroundColor Gray
            Write-Host "=================================================================" -ForegroundColor Cyan
            
            $Choice = Read-Host "   root@$($Category):~# Select Tool"
            
            if ($Choice -eq "B" -or $Choice -eq "b") { break }
            
            if ($Choice -match "^\d+$") {
                $IntChoice = [int]$Choice
                if ($ToolMap.ContainsKey($IntChoice)) {
                    $Script = $ToolMap[$IntChoice]
                    try { & $Script; Write-Host "`n   [+] EXECUTION COMPLETE." -ForegroundColor Gray; Read-Host "   Press Enter..." } 
                    catch { Write-Host "   [!] CRASH: $($_.Exception.Message)" -ForegroundColor Red; Read-Host "   Press Enter..." }
                }
            }
        }
    }

    # --- 6. EVENT LOOP ---
    do {
        Show-MainMenu
        $UserCommand = Read-Host "`n   root@deepsearch:~# Command"
        switch ($UserCommand) {
            "1" { Show-SubMenu "OSINT" }
            "2" { Show-SubMenu "DEFENSE" }
            "3" { Show-SubMenu "OFFENSE" }
            "4" { Show-SubMenu "NET_OPS" }
            "5" { Show-SubMenu "MAINTENANCE" }
            "0" { exit }
        }
    } while ($true)

} catch {
    Write-Host "`n[KERNEL PANIC] SYSTEM CRASHED" -ForegroundColor Red
    Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Yellow
    Read-Host "Press Enter to Exit..."
}