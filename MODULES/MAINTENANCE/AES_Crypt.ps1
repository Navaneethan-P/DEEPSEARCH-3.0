# =============================================================================
# FILE: AES_Crypt.ps1
# LAYER: VAULT (Level 2)
# ARCHITECT: Navaneethan.P
# =============================================================================

# --- CRYPTOGRAPHIC KEYS (Hardcoded for Demo) ---
# In a real enterprise env, these should be in a Key Management Service (KMS).
# AES-256 requires a 32-byte Key and 16-byte IV.
$MasterKey = [System.Text.Encoding]::UTF8.GetBytes("DEEPSEARCH_ZERO_TRUST_MASTER_KEY") # 32 chars
$IV        = [System.Text.Encoding]::UTF8.GetBytes("1234567890123456")                 # 16 chars

function Protect-Data {
    param(
        [Parameter(Mandatory=$true)] [string]$PlainText,
        [Parameter(Mandatory=$true)] [string]$FilePath
    )
    
    try {
        $Aes = [System.Security.Cryptography.Aes]::Create()
        $Aes.Key = $MasterKey
        $Aes.IV = $IV
        
        $Encryptor = $Aes.CreateEncryptor()
        $PlainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
        $EncryptedBytes = $Encryptor.TransformFinalBlock($PlainBytes, 0, $PlainBytes.Length)
        
        [System.IO.File]::WriteAllBytes($FilePath, $EncryptedBytes)
        Write-Host "   [VAULT] Data Encrypted & Sealed -> $FilePath" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "   [ERROR] Encryption Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Unprotect-Data {
    param(
        [Parameter(Mandatory=$true)] [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) { 
        Write-Host "   [VAULT] Error: File not found ($FilePath)" -ForegroundColor Yellow
        return $null 
    }
    
    try {
        $Aes = [System.Security.Cryptography.Aes]::Create()
        $Aes.Key = $MasterKey
        $Aes.IV = $IV
        
        $Decryptor = $Aes.CreateDecryptor()
        $EncryptedBytes = [System.IO.File]::ReadAllBytes($FilePath)
        $PlainBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)
        
        return [System.Text.Encoding]::UTF8.GetString($PlainBytes)
    } catch {
        Write-Host "   [SECURITY ALERT] Decryption Failed." -ForegroundColor Red
        Write-Host "   Possible Causes: Data Tampering or Corrupt Vault." -ForegroundColor Gray
        return $null
    }
}

Write-Host "   [SYSTEM] AES-256 Encryption Engine Loaded." -ForegroundColor DarkGray