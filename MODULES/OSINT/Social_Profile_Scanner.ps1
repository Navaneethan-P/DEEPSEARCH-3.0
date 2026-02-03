# Find usernames across 50+ sites
# =============================================================================
# FILE: Social_Profile_Scanner.ps1
# MODULE: [OSINT] USERNAME RECONNAISSANCE ENGINE
# ARCHITECT: Navaneethan.P
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   SOCIAL SCOUT | USERNAME RECONNAISSANCE" -ForegroundColor White
Write-Host "===================================================================" -ForegroundColor Cyan

# --- 1. CONFIGURATION ---
$TargetUser = Read-Host "   [?] ENTER TARGET USERNAME"
if (-not $TargetUser) { exit }

Write-Host "`n   [HUNTING] Scanning digital footprint for: '$TargetUser'..." -ForegroundColor Yellow
Write-Host ""

# Define Targets (Format: Name, URL Pattern)
# We use {} as a placeholder for the username
$Sites = @(
    @{Name="GitHub";      Url="https://github.com/{}"}
    @{Name="Reddit";      Url="https://www.reddit.com/user/{}"}
    @{Name="Instagram";   Url="https://www.instagram.com/{}/"}
    @{Name="Facebook";    Url="https://www.facebook.com/{}"}
    @{Name="Twitter/X";   Url="https://twitter.com/{}"}
    @{Name="YouTube";     Url="https://www.youtube.com/@{}"}
    @{Name="Pinterest";   Url="https://www.pinterest.com/{}/"}
    @{Name="Steam";       Url="https://steamcommunity.com/id/{}"}
    @{Name="Vimeo";       Url="https://vimeo.com/{}"}
    @{Name="SoundCloud";  Url="https://soundcloud.com/{}"}
    @{Name="Medium";      Url="https://medium.com/@{}"}
    @{Name="Pastebin";    Url="https://pastebin.com/u/{}"}
    @{Name="Wattpad";     Url="https://www.wattpad.com/user/{}"}
    @{Name="Wikipedia";   Url="https://en.wikipedia.org/wiki/User:{}"}
    @{Name="HackerNews";  Url="https://news.ycombinator.com/user?id={}"}
)

# --- 2. EXECUTE SCAN ---
foreach ($Site in $Sites) {
    $CheckUrl = $Site.Url -replace "\{\}", $TargetUser
    
    try {
        # Create a request with a fake User-Agent to avoid blocking
        $Request = [System.Net.WebRequest]::Create($CheckUrl)
        $Request.Method = "HEAD" # We only need headers, not the whole page
        $Request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        $Request.Timeout = 3000 # 3 seconds timeout
        
        $Response = $Request.GetResponse()
        $Code = [int]$Response.StatusCode
        $Response.Close()
        
        if ($Code -eq 200) {
            Write-Host "   [FOUND] $($Site.Name)" -NoNewline -ForegroundColor Green
            Write-Host " -> $CheckUrl" -ForegroundColor White
        }
    } catch {
        # Catch 404s (Not Found)
        $Ex = $_.Exception
        if ($Ex.Response.StatusCode -eq [System.Net.HttpStatusCode]::NotFound) {
            # 404 means user does not exist
            Write-Host "   [MISSING] $($Site.Name)" -ForegroundColor DarkGray
        } else {
            # Other errors (Timeouts, 403 Forbidden)
            Write-Host "   [ERROR] $($Site.Name) (Protected/Blocked)" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "   [INFO] Scan Complete." -ForegroundColor Gray
Read-Host "   Press Enter to return to Kernel..."