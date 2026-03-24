# Claude Setup Script for Windows
# Installs Claude desktop app, Claude Code CLI, and copies settings/plugins
# Run as: powershell -ExecutionPolicy RemoteSigned -File setup-windows.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = Split-Path -Parent $ScriptDir
$SettingsDir = Join-Path $ConfigDir "settings"

function Write-Info  { param($msg) Write-Host "[+] $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[x] $msg" -ForegroundColor Red }

# Prompt helper: ask Y/n (default yes)
function Confirm-Install {
    param($Prompt)
    $reply = Read-Host "[?] $Prompt [Y/n]"
    return ($reply -eq "" -or $reply -eq "y" -or $reply -eq "Y")
}

Write-Host ""
Write-Host "=============================="
Write-Host "  Claude Setup for Windows"
Write-Host "=============================="
Write-Host ""

# -------------------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------------------
$hasNode = Get-Command node -ErrorAction SilentlyContinue
if (-not $hasNode) {
    Write-Warn "Node.js not found."
    Write-Host "  Install from https://nodejs.org/ or via winget:"
    Write-Host "  winget install OpenJS.NodeJS.LTS"
    Write-Host ""
    $install = Read-Host "Attempt install via winget now? (y/n)"
    if ($install -eq "y") {
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    } else {
        Write-Err "Node.js is required. Exiting."
        exit 1
    }
}

# -------------------------------------------------------------------
# 2. Install Claude Desktop App
# -------------------------------------------------------------------
$claudeAppPath = Join-Path $env:LOCALAPPDATA "Programs\claude-desktop"
$claudeInstalled = Test-Path (Join-Path $claudeAppPath "Claude.exe") -ErrorAction SilentlyContinue

if ($claudeInstalled) {
    Write-Info "Claude desktop app already installed"
} else {
    Write-Info "Attempting to install Claude desktop app via winget..."
    try {
        winget install Anthropic.Claude --accept-package-agreements --accept-source-agreements
        Write-Info "Claude desktop app installed"
    } catch {
        Write-Warn "Could not install via winget. Download manually from https://claude.ai/download"
    }
}

# -------------------------------------------------------------------
# 3. Install Claude Code CLI
# -------------------------------------------------------------------
$hasClaude = Get-Command claude -ErrorAction SilentlyContinue
if ($hasClaude) {
    Write-Info "Claude Code CLI already installed"
} else {
    Write-Info "Installing Claude Code CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    Write-Info "Claude Code CLI installed"
}

# -------------------------------------------------------------------
# 4. Create directory structure
# -------------------------------------------------------------------
$claudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Info "Creating Claude config directories..."
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

# -------------------------------------------------------------------
# 5. Copy Claude Code CLI settings
# -------------------------------------------------------------------
$settingsFile = Join-Path $claudeDir "settings.json"
if (Test-Path $settingsFile) {
    Write-Warn "settings.json already exists - backing up to settings.json.bak"
    Copy-Item $settingsFile "$settingsFile.bak"
}
Write-Info "Copying Claude Code CLI settings..."
Copy-Item (Join-Path $SettingsDir "claude-code-settings.json") $settingsFile

# -------------------------------------------------------------------
# 6. Install plugins
# -------------------------------------------------------------------
Write-Info "Installing Claude Code plugins..."
Write-Info "Run these inside a Claude Code session (start with 'claude'):"
Write-Host "  /plugin install frontend-design@claude-plugins-official"
Write-Host "  /plugin install superpowers@claude-plugins-official"
Write-Host "  /plugin install claude-md-management@claude-plugins-official"
Write-Host "  /plugin install context7@claude-plugins-official"
Write-Host ""
Write-Info "Or run /plugin to browse and install from the plugin manager UI"
Write-Host ""
Write-Info "After installing plugins, run /reload-plugins to activate them"

# -------------------------------------------------------------------
# 7. Configure statusline from shell prompt
# -------------------------------------------------------------------
Write-Info "Configuring statusline..."
Write-Info "Run /statusline inside a Claude Code session to configure your status bar"

# -------------------------------------------------------------------
# 8. Copy Claude Desktop App preferences
# -------------------------------------------------------------------
$claudeAppDir = Join-Path $env:APPDATA "Claude"
New-Item -ItemType Directory -Force -Path $claudeAppDir | Out-Null

$desktopConfig = Join-Path $claudeAppDir "claude_desktop_config.json"
if (Test-Path $desktopConfig) {
    Write-Warn "Desktop config already exists - backing up to claude_desktop_config.json.bak"
    Copy-Item $desktopConfig "$desktopConfig.bak"
}

Write-Info "Copying Claude desktop app preferences..."
Copy-Item (Join-Path $SettingsDir "claude_desktop_config.json") $desktopConfig

# -------------------------------------------------------------------
# 9. Copy example CLAUDE.md
# -------------------------------------------------------------------
$examplePath = Join-Path $env:USERPROFILE "example-CLAUDE.md"
if (-not (Test-Path $examplePath)) {
    Write-Info "Placing example CLAUDE.md in home directory for reference..."
    Copy-Item (Join-Path $SettingsDir "example-CLAUDE.md") $examplePath
} else {
    Write-Warn "example-CLAUDE.md already exists in home directory - skipping"
}

# -------------------------------------------------------------------
# 10. Optional third-party tools
# -------------------------------------------------------------------
Write-Host ""
Write-Host "------------------------------"
Write-Host "  Optional Tools"
Write-Host "------------------------------"
Write-Host ""

# Docker Desktop
$hasDocker = Get-Command docker -ErrorAction SilentlyContinue
if ($hasDocker) {
    Write-Info "Docker already installed"
} else {
    if (Confirm-Install "Install Docker Desktop?") {
        winget install Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
        Write-Info "Docker Desktop installed — restart may be required"
    }
}

# Google Chrome
$chromeInstalled = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
if ($chromeInstalled) {
    Write-Info "Google Chrome already installed"
} else {
    if (Confirm-Install "Install Google Chrome?") {
        winget install Google.Chrome --accept-package-agreements --accept-source-agreements
        Write-Info "Google Chrome installed"
    }
}

# Chrome extensions (only if Chrome is installed)
$chromeInstalled = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
if ($chromeInstalled) {
    if (Confirm-Install "Install Claude Chrome extension?") {
        Start-Process "https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"
        Write-Info "Opened Claude extension page in Chrome - click 'Add to Chrome' to install"
    }

    if (Confirm-Install "Install Markdown Viewer Chrome extension?") {
        Start-Process "https://chromewebstore.google.com/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk"
        Write-Info "Opened Markdown Viewer extension page in Chrome - click 'Add to Chrome' to install"
    }
}

# Visual Studio Code
$hasCode = Get-Command code -ErrorAction SilentlyContinue
$vscodeInstalled = (Test-Path "C:\Program Files\Microsoft VS Code\Code.exe") -or $hasCode
if ($vscodeInstalled) {
    Write-Info "Visual Studio Code already installed"
} else {
    if (Confirm-Install "Install Visual Studio Code?") {
        winget install Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
        Write-Info "Visual Studio Code installed"
        # Refresh PATH so code command is available
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    }
}

# VS Code CLI (code command)
$hasCode = Get-Command code -ErrorAction SilentlyContinue
if ($hasCode) {
    Write-Info "VS Code CLI (code) already available"
} else {
    if (Test-Path "C:\Program Files\Microsoft VS Code\bin\code.cmd") {
        if (Confirm-Install "Add VS Code CLI (code command) to PATH?") {
            $vscodeBin = "C:\Program Files\Microsoft VS Code\bin"
            $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
            if ($currentPath -notlike "*$vscodeBin*") {
                [System.Environment]::SetEnvironmentVariable("PATH", "$currentPath;$vscodeBin", "User")
                $env:PATH += ";$vscodeBin"
                Write-Info "VS Code CLI added to PATH"
            }
        }
    } else {
        Write-Warn "VS Code not installed - skipping CLI tool"
    }
}

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
Write-Host ""
Write-Host "=============================="
Write-Host "  Setup complete!"
Write-Host "=============================="
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Open Claude and sign in"
Write-Host "  2. Run 'claude' in a terminal to start Claude Code CLI"
Write-Host "  3. Create CLAUDE.md files in your project roots (see example-CLAUDE.md)"
Write-Host ""
