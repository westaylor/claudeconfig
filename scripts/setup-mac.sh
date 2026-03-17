#!/bin/bash
set -euo pipefail

# Claude Setup Script for macOS
# Installs Claude desktop app, Claude Code CLI, and copies settings/plugins

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
SETTINGS_DIR="$CONFIG_DIR/settings"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# Prompt helper: ask Y/n (default yes)
confirm() {
    local prompt="$1"
    local reply
    read -r -p "$(echo -e "${YELLOW}[?]${NC} ${prompt} [Y/n] ")" reply
    [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]
}

echo ""
echo "=============================="
echo "  Claude Setup for macOS"
echo "=============================="
echo ""

# -------------------------------------------------------------------
# 1. Check prerequisites
# -------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
    warn "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v node &>/dev/null; then
    warn "Node.js not found. Installing via Homebrew..."
    brew install node
fi

# -------------------------------------------------------------------
# 2. Install Claude Desktop App
# -------------------------------------------------------------------
if [ -d "/Applications/Claude.app" ]; then
    info "Claude desktop app already installed"
else
    info "Installing Claude desktop app via Homebrew Cask..."
    if brew install --cask claude 2>/dev/null; then
        info "Claude desktop app installed"
    else
        warn "Could not install via Homebrew. Download manually from https://claude.ai/download"
    fi
fi

# -------------------------------------------------------------------
# 3. Install Claude Code CLI
# -------------------------------------------------------------------
if command -v claude &>/dev/null; then
    info "Claude Code CLI already installed: $(claude --version 2>/dev/null || echo 'unknown version')"
else
    info "Installing Claude Code CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    info "Claude Code CLI installed"
fi

# -------------------------------------------------------------------
# 4. Create directory structure
# -------------------------------------------------------------------
info "Creating Claude config directories..."
mkdir -p ~/.claude

# -------------------------------------------------------------------
# 5. Copy Claude Code CLI settings
# -------------------------------------------------------------------
if [ -f ~/.claude/settings.json ]; then
    warn "~/.claude/settings.json already exists — backing up to settings.json.bak"
    cp ~/.claude/settings.json ~/.claude/settings.json.bak
fi
info "Copying Claude Code CLI settings..."
cp "$SETTINGS_DIR/claude-code-settings.json" ~/.claude/settings.json
sed -i '' "s/__USERNAME__/$(whoami)/g" ~/.claude/settings.json

# -------------------------------------------------------------------
# 6. Install plugins
# -------------------------------------------------------------------
info "Installing Claude Code plugins..."
claude install plugin frontend-design@claude-plugins-official
claude install plugin superpowers@claude-plugins-official
claude install plugin claude-md-management@claude-plugins-official
claude install plugin context7@claude-plugins-official

# -------------------------------------------------------------------
# 7. Configure statusline from shell prompt
# -------------------------------------------------------------------
info "Configuring statusline..."
claude /statusline

# -------------------------------------------------------------------
# 8. Copy Claude Desktop App preferences
# -------------------------------------------------------------------
CLAUDE_APP_DIR="$HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_APP_DIR"

if [ -f "$CLAUDE_APP_DIR/claude_desktop_config.json" ]; then
    warn "Desktop config already exists — backing up to claude_desktop_config.json.bak"
    cp "$CLAUDE_APP_DIR/claude_desktop_config.json" "$CLAUDE_APP_DIR/claude_desktop_config.json.bak"
fi

info "Copying Claude desktop app preferences..."
cp "$SETTINGS_DIR/claude_desktop_config.json" "$CLAUDE_APP_DIR/claude_desktop_config.json"

# -------------------------------------------------------------------
# 9. Copy example CLAUDE.md
# -------------------------------------------------------------------
info "Placing example CLAUDE.md in home directory for reference..."
if [ ! -f ~/CLAUDE.md ]; then
    cp "$SETTINGS_DIR/example-CLAUDE.md" ~/example-CLAUDE.md
    info "Saved as ~/example-CLAUDE.md (rename and move to a project root to use)"
else
    warn "~/CLAUDE.md already exists — skipping example copy"
fi

# -------------------------------------------------------------------
# 10. Optional third-party tools
# -------------------------------------------------------------------
echo ""
echo "------------------------------"
echo "  Optional Tools"
echo "------------------------------"
echo ""

# Docker (Colima + Docker CLI)
if command -v colima &>/dev/null && command -v docker &>/dev/null; then
    info "Colima and Docker CLI already installed"
else
    if confirm "Install Docker (via Colima)?"; then
        if ! command -v docker &>/dev/null; then
            brew install docker
            info "Docker CLI installed"
        fi
        if ! command -v colima &>/dev/null; then
            brew install colima
            info "Colima installed"
        fi
        colima start --memory 2 --cpu 2 --disk 60
        brew services start colima
        info "Colima started and set to run on login"
        # Point /var/run/docker.sock to colima so the sandbox can access it
        if [ -S "$HOME/.colima/default/docker.sock" ]; then
            sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
            docker context use default
            info "Docker socket linked to /var/run/docker.sock"
        fi
    fi
fi

# Ghostty terminal
if [ -d "/Applications/Ghostty.app" ]; then
    info "Ghostty already installed"
else
    if confirm "Install Ghostty terminal?"; then
        brew install --cask ghostty
        info "Ghostty installed"
    fi
fi

# Google Chrome
if [ -d "/Applications/Google Chrome.app" ]; then
    info "Google Chrome already installed"
else
    if confirm "Install Google Chrome?"; then
        brew install --cask google-chrome
        info "Google Chrome installed"
    fi
fi

# Chrome extensions (only if Chrome is installed)
if [ -d "/Applications/Google Chrome.app" ]; then
    if confirm "Install Claude Chrome extension?"; then
        open "https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn"
        info "Opened Claude extension page in Chrome — click 'Add to Chrome' to install"
    fi

    if confirm "Install Markdown Viewer Chrome extension?"; then
        open "https://chromewebstore.google.com/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk"
        info "Opened Markdown Viewer extension page in Chrome — click 'Add to Chrome' to install"
    fi
fi

# Visual Studio Code
if [ -d "/Applications/Visual Studio Code.app" ]; then
    info "Visual Studio Code already installed"
else
    if confirm "Install Visual Studio Code?"; then
        brew install --cask visual-studio-code
        info "Visual Studio Code installed"
    fi
fi

# VS Code CLI (code command)
if command -v code &>/dev/null; then
    info "VS Code CLI (code) already available"
else
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        if confirm "Install VS Code CLI tool (code command)?"; then
            # Symlink the code binary into /usr/local/bin
            ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
            info "VS Code CLI linked to /usr/local/bin/code"
        fi
    else
        warn "VS Code not installed — skipping CLI tool"
    fi
fi

# -------------------------------------------------------------------
# Done
# -------------------------------------------------------------------
echo ""
echo "=============================="
echo "  Setup complete!"
echo "=============================="
echo ""
info "Next steps:"
echo "  1. Open Claude.app and sign in"
echo "  2. Run 'claude' in a terminal to start Claude Code CLI"
echo "  3. Create CLAUDE.md files in your project roots (see example-CLAUDE.md)"
echo ""
