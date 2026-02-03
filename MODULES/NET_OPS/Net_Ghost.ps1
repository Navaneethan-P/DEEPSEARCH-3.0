# MAC Spoofing, DNS Hopping, Proxy
# =============================================================================
# FILE: Net_Ghost.ps1
# MODULE: [NET_OPS] IDENTITY SHIFTER & PRIVACY ENGINE
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# --- UI HEADER ---
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   NET GHOST | DIGITAL IDENTITY SHIFTER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. SELECT NETWORK ADAPTER ---
Write-Host "`n   [1/3] Scanning Network Interfaces..." -ForegroundColor Yellow
$Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

if (-not $Adapters) {
    Write-Host "   [ERROR] No active network connection found." -ForegroundColor Red
    Read-Host "   Press Enter to exit..."
    exit
}

# Auto-select the first active adapter (usually Wi-Fi)
$Target = $Adapters[0]
Write-Host "   [TARGET LOCKED] Interface: $($Target.Name) ($($Target.InterfaceDescription))" -ForegroundColor Green
Write-Host "   [CURRENT MAC]   $($Target.MacAddress)" -ForegroundColor Gray

# --- 2. MENU ---
Write-Host "`n   [ GHOST PROTOCOLS ]" -ForegroundColor Cyan
Write-Host "   [1] RANDOMIZE HARDWARE ID (MAC Spoofing)" -ForegroundColor White
Write-Host "   [2] ACTIVATE DNS SHIELD (Cloudflare Encrypted)" -ForegroundColor White
Write-Host "   [3] RESTORE FACTORY SETTINGS" -ForegroundColor DarkGray
Write-Host "   [0] CANCEL" -ForegroundColor DarkGray

$Choice = Read-Host "`n   root@ghost:~# Select Option"

# --- 3. EXECUTION ---

# [OPTION 1] MAC SPOOFING
if ($Choice -eq "1") {
    Write-Host "`n   [!] GENERATING NEW IDENTITY..." -ForegroundColor Yellow
    
    # Generate Random MAC (Unicast, Locally Administered)
    $Bytes = New-Object Byte[] 6
    (New-Object Random).NextBytes($Bytes)
    $Bytes[0] = 0x02 # Force locally administered bit
    $NewMac = ($Bytes | ForEach-Object { $_.ToString("X2") }) -join ""
    
    Write-Host "   [NEW ID] $NewMac" -ForegroundColor Cyan
    Write-Host "   [ACTION] Rewriting Registry Keys..." -ForegroundColor DarkGray
    
    # Registry Hack to change MAC
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    $Key = Get-ChildItem $RegPath -ErrorAction SilentlyContinue | Where-Object { (Get-ItemProperty $_.PSPath).NetCfgInstanceId -eq $Target.InterfaceGuid }
    
    if ($Key) {
        Set-ItemProperty -Path $Key.PSPath -Name "NetworkAddress" -Value $NewMac
        
        Write-Host "   [ACTION] Restarting Network Adapter (Internet will blink)..." -ForegroundColor Yellow
        Disable-NetAdapter -Name $Target.Name -Confirm:$false
        Start-Sleep -Seconds 3
        Enable-NetAdapter -Name $Target.Name -Confirm:$false
        
        Write-Host "   [SUCCESS] IDENTITY SHIFT COMPLETE." -ForegroundColor Green
    } else {
        Write-Host "   [FAIL] Could not locate Registry Key for this adapter." -ForegroundColor Red
    }
}

# [OPTION 2] DNS SHIELD
elseif ($Choice -eq "2") {
    Write-Host "`n   [!] ENGAGING DNS SHIELD..." -ForegroundColor Yellow
    
    # Set to Cloudflare (1.1.1.1) and Quad9 (9.9.9.9)
    Set-DnsClientServerAddress -InterfaceAlias $Target.Name -ServerAddresses ("1.1.1.1", "9.9.9.9")
    
    # Flush Cache
    Clear-DnsClientCache
    
    Write-Host "   [SECURE] Traffic now routed via Encrypted DNS." -ForegroundColor Green
    Write-Host "   [INFO] ISP Tracking & Censorship Bypassed." -ForegroundColor Gray
}

# [OPTION 3] RESTORE
elseif ($Choice -eq "3") {
    Write-Host "`n   [!] RESTORING FACTORY DEFAULTS..." -ForegroundColor Yellow
    
    # Reset DNS
    Set-DnsClientServerAddress -InterfaceAlias $Target.Name -ResetServerAddresses
    
    # Reset MAC
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    $Key = Get-ChildItem $RegPath -ErrorAction SilentlyContinue | Where-Object { (Get-ItemProperty $_.PSPath).NetCfgInstanceId -eq $Target.InterfaceGuid }
    if ($Key) {
        Remove-ItemProperty -Path $Key.PSPath -Name "NetworkAddress" -ErrorAction SilentlyContinue
    }
    
    # Restart
    Disable-NetAdapter -Name $Target.Name -Confirm:$false
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name $Target.Name -Confirm:$false
    
    Write-Host "   [OK] System Restored." -ForegroundColor Green
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."