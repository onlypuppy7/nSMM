# windows is absolutely abysmal at package management
# as well as path management. i hate it so much.

# set lua directory (short path to avoid spaces/parentheses)
$LOVE_DIR = "C:\Program Files\LOVE"

# add lua directory to PATH for this session
$env:PATH += ";$LOVE_DIR"

# check if lua.exe is available
if (-not (Get-Command love -ErrorAction SilentlyContinue)) {
    Write-Host "LOVE executable not found in PATH."
    Write-Host "Attempting to install LOVE for Windows via winget..."

    # check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Please install winget or install LOVE manually."
        Pause
        exit 1
    }

    # install lua for windows "silently"
    $install = winget install -e --id Love2d.Love2d
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install LOVE for Windows via winget."
        Pause
        exit 1
    }

    Write-Host "Installation complete."

}

# permanently add LOVE dir to user PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($userPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ieq $LOVE_DIR })) {
    $newPath = if ([string]::IsNullOrEmpty($userPath)) { $LOVE_DIR } else { "$userPath;$LOVE_DIR" }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added LOVE directory to user PATH permanently."
} else {
    Write-Host "LOVE directory is already in user PATH."
}

# verify lua now exists
if (-not (Get-Command lua -ErrorAction SilentlyContinue)) {
    Write-Host "LOVE executable still not found after installation."
    Pause
    exit 1
}

# show lua version
love --version