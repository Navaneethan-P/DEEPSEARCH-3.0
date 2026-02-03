# Predictive Performance History
# =============================================================================
# FILE: Titan_Health.ps1
# MODULE: [MAINTENANCE] PREDICTIVE PERFORMANCE & HEALTH MONITOR
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

# --- PATH CONFIGURATION ---
$Root = "$PSScriptRoot\..\.."
$DataDir = "$Root\DATA"
$LogFile = "$DataDir\titan_perf_log.csv"

# Ensure Data Warehouse exists
if (-not (Test-Path $DataDir)) { New-Item -Path $DataDir -ItemType Directory -Force | Out-Null }

# Initialize Log if missing
if (-not (Test-Path $LogFile)) {
    "Timestamp,BootTime_Sec,CPU_Load,RAM_Used_GB,Disk_Free_GB" | Out-File $LogFile -Encoding UTF8
}

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   TITAN HEALTH | PREDICTIVE MAINTENANCE ENGINE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. COLLECT REAL-TIME TELEMETRY ---
Write-Host "   [1/3] Measuring System Vitals..." -ForegroundColor Yellow

# CPU Load (Average of 5 samples for accuracy)
$CpuPoints = 0
1..5 | ForEach-Object {
    $CpuPoints += (Get-CimInstance Win32_Processor).LoadPercentage
    Start-Sleep -Milliseconds 200
}
$CpuLoad = [math]::Round($CpuPoints / 5)

# RAM Usage
$OS = Get-CimInstance Win32_OperatingSystem
$TotalRAM = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
$FreeRAM = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
$UsedRAM = [math]::Round($TotalRAM - $FreeRAM, 2)
$RamPercent = [math]::Round(($UsedRAM / $TotalRAM) * 100)

# Disk Space (C:)
$Disk = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
$FreeDisk = [math]::Round($Disk.FreeSpace / 1GB, 2)

# Last Boot Time (Uptime Calculation)
$BootTime = $OS.LastBootUpTime
$Uptime = (Get-Date) - $BootTime
$BootSeconds = [math]::Round((New-TimeSpan -Start $BootTime -End (Get-Date)).TotalSeconds) 
# Note: Accurate "Boot Duration" is hard to get without Event Log mining, 
# so we track "Time Since Last Boot" to detect stale sessions.

# --- 2. LOG DATA TO WAREHOUSE ---
Write-Host "   [2/3] Writing to Data Warehouse..." -ForegroundColor Yellow
$DateStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$DateStr,$BootSeconds,$CpuLoad,$UsedRAM,$FreeDisk" | Out-File $LogFile -Append -Encoding UTF8
Write-Host "         [OK] Data Point Saved." -ForegroundColor DarkGray

# --- 3. PREDICTIVE ANALYSIS (HISTORY CHECK) ---
Write-Host "`n   [3/3] ANALYZING HEALTH TRENDS..." -ForegroundColor Yellow
Write-Host "   -------------------------------------------------------" -ForegroundColor DarkGray

# Import History
$History = Import-Csv $LogFile
$Count = $History.Count

if ($Count -gt 1) {
    # Calculate Averages
    $AvgCPU = ($History | Measure-Object CPU_Load -Average).Average
    $AvgRAM = ($History | Measure-Object RAM_Used_GB -Average).Average
    
    # --- CPU REPORT ---
    Write-Host "   [CPU]" -NoNewline
    if ($CpuLoad -gt ($AvgCPU + 20)) {
        Write-Host " WARN: High Load ($CpuLoad%) vs Avg ($([math]::Round($AvgCPU))%)" -ForegroundColor Red
        Write-Host "         -> Recommendation: Check for background miners or stuck processes." -ForegroundColor Gray
    } else {
        Write-Host " HEALTHY: Load ($CpuLoad%) is normal." -ForegroundColor Green
    }
    
    # --- RAM REPORT ---
    Write-Host "   [RAM]" -NoNewline
    if ($UsedRAM -gt ($AvgRAM + 2)) {
        Write-Host " WARN: Usage ($UsedRAM GB) is higher than usual ($([math]::Round($AvgRAM)) GB)" -ForegroundColor Yellow
    } else {
        Write-Host " HEALTHY: Usage ($UsedRAM GB) is within baseline." -ForegroundColor Green
    }
    
    # --- DISK PREDICTION ---
    Write-Host "   [HDD]" -NoNewline
    if ($FreeDisk -lt 10) {
        Write-Host " CRITICAL: Low Space ($FreeDisk GB). Clean immediately." -ForegroundColor Red
    } else {
        Write-Host " HEALTHY: $FreeDisk GB Free." -ForegroundColor Green
    }

} else {
    Write-Host "   [INFO] Not enough data for prediction. Run this tool daily to build history." -ForegroundColor Gray
}

# --- SMART DRIVE CHECK (Hardware Health) ---
Write-Host "`n   [HARDWARE SELF-TEST]" -ForegroundColor Yellow
try {
    $Smart = Get-Disk | Where-Object { $_.HealthStatus -ne "Healthy" }
    if ($Smart) {
        Write-Host "   [!] CRITICAL HARDWARE WARNING: DRIVE FAILURE IMMINENT!" -ForegroundColor Red
    } else {
        Write-Host "   [OK] All Physical Drives report 'Healthy' status." -ForegroundColor Green
    }
} catch {
    Write-Host "   [?] Could not access S.M.A.R.T data." -ForegroundColor DarkGray
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."