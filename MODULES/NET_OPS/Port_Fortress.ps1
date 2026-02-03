# Visual Firewall Manager
# =============================================================================
# FILE: Port_Fortress.ps1
# MODULE: [NET_OPS] VISUAL FIREWALL MANAGER
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"

function Show-Ports {
    Clear-Host
    Write-Host "===================================================================" -ForegroundColor Cyan
    Write-Host "   PORT FORTRESS | VISUAL FIREWALL CONTROLLER" -ForegroundColor White
    Write-Host "===================================================================" -ForegroundColor Cyan
    
    # Get Listening TCP Ports
    Write-Host "   [ LISTENING PORTS (OPEN DOORS) ]" -ForegroundColor Yellow
    Write-Host "   Local Address   Port    PID     Process Name" -ForegroundColor DarkGray
    Write-Host "   ----------------------------------------------------" -ForegroundColor DarkGray
    
    $Connections = Get-NetTCPConnection -State Listen | Sort-Object LocalPort
    
    foreach ($Con in $Connections) {
        $Process = Get-Process -Id $Con.OwningProcess -ErrorAction SilentlyContinue
        $Name = if ($Process) { $Process.ProcessName } else { "System/Unknown" }
        
        # Color coding: High risk ports in Red
        $RiskColor = "White"
        if ($Con.LocalPort -in 445, 3389, 135, 139, 21, 23) { $RiskColor = "Red" }
        
        Write-Host ("   {0,-15} {1,-7} {2,-7} {3}" -f $Con.LocalAddress, $Con.LocalPort, $Con.OwningProcess, $Name) -ForegroundColor $RiskColor
    }
    Write-Host ""
}

function Add-Rule ($Action, $Port) {
    $RuleName = "DeepSearch_$Action_$Port"
    
    if ($Action -eq "Block") {
        New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Block -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName $RuleName -Direction Outbound -LocalPort $Port -Protocol TCP -Action Block -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   [SECURE] Port $Port BLOCKED (Inbound/Outbound)." -ForegroundColor Red
    } elseif ($Action -eq "Allow") {
        New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -LocalPort $Port -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
        Write-Host "   [OPEN] Port $Port ALLOWED." -ForegroundColor Green
    }
}

# --- MAIN LOOP ---
while ($true) {
    Show-Ports
    
    Write-Host "   [COMMANDS]" -ForegroundColor Cyan
    Write-Host "   block <port>   :: Close a port (e.g., 'block 445')" -ForegroundColor Gray
    Write-Host "   allow <port>   :: Open a port (e.g., 'allow 80')" -ForegroundColor Gray
    Write-Host "   list           :: Show Active Firewall Rules" -ForegroundColor Gray
    Write-Host "   0              :: Exit" -ForegroundColor Gray
    Write-Host "===================================================================" -ForegroundColor Cyan
    
    $Cmd = Read-Host "   root@fortress:~# Command"
    
    if ($Cmd -eq "0") { break }
    
    if ($Cmd -match "^block (\d+)") {
        Add-Rule "Block" $matches[1]
        Start-Sleep -Seconds 2
    }
    elseif ($Cmd -match "^allow (\d+)") {
        Add-Rule "Allow" $matches[1]
        Start-Sleep -Seconds 2
    }
    elseif ($Cmd -eq "list") {
        Clear-Host
        Write-Host "   [ ACTIVE DEEPSEARCH RULES ]" -ForegroundColor Yellow
        Get-NetFirewallRule | Where-Object { $_.DisplayName -like "DeepSearch*" } | Select-Object DisplayName, Action, Direction | Format-Table -AutoSize
        Read-Host "   Press Enter to continue..."
    }
}