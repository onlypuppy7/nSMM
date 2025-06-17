# YOU DONT NEED THIS TO BUILD NSMM

# windows is absolutely abysmal at package management
# as well as path management. i hate it so much.

# set lua directory (short path to avoid spaces/parentheses)
$LUA_DIR = "C:\Program Files (x86)\Lua\5.1"

# add lua directory to PATH for this session
$env:PATH += ";$LUA_DIR"

# check if lua.exe is available
if (-not (Get-Command lua -ErrorAction SilentlyContinue)) {
    Write-Host "Lua executable not found in PATH."
    Write-Host "Attempting to install Lua for Windows via winget..."

    # check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found. Please install winget or install Lua manually."
        Pause
        exit 1
    }

    # install lua for windows "silently"
    $install = winget install --accept-package-agreements --accept-source-agreements --silent --id rjpcomputing.luaforwindows
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install Lua for Windows via winget."
        Pause
        exit 1
    }

    Write-Host "Installation complete."

}

# permanently add Lua dir to user PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if (-not ($userPath -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ieq $LUA_DIR })) {
    $newPath = if ([string]::IsNullOrEmpty($userPath)) { $LUA_DIR } else { "$userPath;$LUA_DIR" }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added Lua directory to user PATH permanently."
} else {
    Write-Host "Lua directory is already in user PATH."
}

# verify lua now exists
if (-not (Get-Command lua -ErrorAction SilentlyContinue)) {
    Write-Host "Lua executable still not found after installation."
    Pause
    exit 1
}

# show lua version
lua -v