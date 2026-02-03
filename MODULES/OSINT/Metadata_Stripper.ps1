# Clean GPS/Author data from photos
# =============================================================================
# FILE: Metadata_Stripper.ps1
# MODULE: [OSINT] EXIF DATA CLEANER (DIGITAL SHREDDER)
# ARCHITECT: Navaneethan.P
# =============================================================================

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   METADATA STRIPPER | EXIF DATA SHREDDER" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. INPUT FILE ---
# We use a file dialog to make it easier to pick an image
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Title = "Select Image to Sanitize"
$OpenFileDialog.Filter = "Image Files|*.jpg;*.jpeg;*.png"
$OpenFileDialog.InitialDirectory = [Environment]::GetFolderPath("MyPictures")

Write-Host "   [INPUT] Waiting for file selection..." -ForegroundColor Yellow
$Result = $OpenFileDialog.ShowDialog()

if ($Result -eq "Cancel") {
    Write-Host "   [ABORT] No file selected." -ForegroundColor Red
    Read-Host "   Press Enter to exit..."
    exit
}

$FilePath = $OpenFileDialog.FileName
$FileInfo = Get-Item $FilePath
Write-Host "   [LOADED] $($FileInfo.Name)" -ForegroundColor White
Write-Host "   [SIZE]   $([math]::Round($FileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray

# --- 2. ANALYZE METADATA ---
try {
    # Load Image in memory
    $Image = [System.Drawing.Image]::FromFile($FilePath)
    $PropCount = $Image.PropertyItems.Count
    
    if ($PropCount -gt 0) {
        Write-Host "   [ALERT] Found $PropCount hidden data tags (EXIF/GPS)." -ForegroundColor Red
        
        # --- 3. SANITIZE ---
        Write-Host "   [ACTION] Scrubbing metadata..." -ForegroundColor Yellow
        
        # Create a new blank bitmap with the same dimensions
        $CleanImage = New-Object System.Drawing.Bitmap($Image)
        
        # We don't copy the PropertyItems, effectively stripping them.
        # To be absolutely sure, we create a fresh bitmap copy which drops metadata by default.
        
        # Construct Output Name
        $Dir = [System.IO.Path]::GetDirectoryName($FilePath)
        $Name = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
        $Ext = [System.IO.Path]::GetExtension($FilePath)
        $NewPath = "$Dir\$Name`_CLEAN$Ext"
        
        # Save Clean Copy
        $CleanImage.Save($NewPath)
        
        # Cleanup Memory
        $CleanImage.Dispose()
        $Image.Dispose()
        
        Write-Host "   [SUCCESS] Clean image saved:" -ForegroundColor Green
        Write-Host "   [PATH] $NewPath" -ForegroundColor White
        Write-Host "   [INFO] GPS and Device data removed." -ForegroundColor Gray
        
    } else {
        Write-Host "   [OK] Image is already clean. No metadata found." -ForegroundColor Green
        $Image.Dispose()
    }

} catch {
    Write-Host "   [ERROR] Failed to process image." -ForegroundColor Red
    Write-Host "   Details: $($_.Exception.Message)" -ForegroundColor DarkGray
}

Write-Host ""
Read-Host "   Press Enter to return to Kernel..."