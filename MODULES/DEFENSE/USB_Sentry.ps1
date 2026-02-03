# =============================================================================
# FILE: USB_Sentry.ps1
# MODULE: [3] HARDWARE WATCHDOG
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   USB SENTRY | REAL-TIME HARDWARE MONITOR" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n   [SYSTEM] INITIALIZING EVENT WATCHER..." -ForegroundColor Yellow

# Query: Watch for __InstanceCreationEvent where the Target is a PnP Entity
$Query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_PnPEntity'"
$Watcher = New-Object System.Management.ManagementEventWatcher($Query)

# Define the Action block
$Action = {
    $Device = $Event.SourceEventArgs.NewEvent.TargetInstance
    
    # Filter only for USB devices (Mass Storage, Human Interface, etc.)
    if ($Device.DeviceID -match "USB") {
        Write-Host ""
        Write-Host "   [ALERT] HARDWARE CONNECTION DETECTED!" -ForegroundColor White -BackgroundColor Red
        Write-Host "   [INFO] Name:        $($Device.Name)" -ForegroundColor Yellow
        Write-Host "   [INFO] Description: $($Device.Description)" -ForegroundColor Yellow
        Write-Host "   [INFO] Device ID:   $($Device.DeviceID)" -ForegroundColor Red
        Write-Host "   [LOG] Event timestamped." -ForegroundColor Gray
        
        # Audio Alert
        [Console]::Beep(600, 300)
    }
}

# Register the Event
Register-ObjectEvent -InputObject $Watcher -EventName "EventArrived" -Action $Action | Out-Null

Write-Host "   [SECURE] SENTRY ARMED. WAITING FOR DEVICES..." -ForegroundColor Green
Write-Host "   (Press Ctrl+C to stop monitoring)" -ForegroundColor Gray

# Infinite Keep-Alive Loop
while ($true) { Start-Sleep -Seconds 1 }