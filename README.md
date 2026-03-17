# Claude Setup Guide

A slim, ready-to-go configuration for the Claude desktop app and Claude Code CLI. It installs only a handful of major tools, requires no accounts besides Claude, and can be up and running in minutes.

## Quick Start

### macOS

```bash
chmod +x scripts/setup-mac.sh
./scripts/setup-mac.sh
```

### Windows (PowerShell as Administrator)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\setup-windows.ps1
```

## Post-Install Steps

1. **Authenticate Claude** - Open the Claude desktop app and sign in with your Anthropic account
2. **Plugins** - The setup script installs plugins automatically via `claude install plugin`
3. **Enable Chrome remote debugging** - Required for the Claude in Chrome MCP server to control your browser:
   - In Chrome, go to `chrome://inspect/#remote-debugging` and check the "Enable remote debugging" box (Chrome 146+)
4. **Create project CLAUDE.md files** - Use `example-CLAUDE.md` as a template for your own projects

---

## What does this set up?

- **Claude desktop app** — The main Claude application for chatting, coworking, and running code
- **Claude Code CLI** — A command-line tool that lets Claude read, write, and run code directly in your projects
- **Four plugins** that make Claude smarter:
  - **superpowers** — Structured workflows for planning, debugging, brainstorming, and code review
  - **frontend-design** — Helps build polished, professional web interfaces
  - **context7** — Looks up current documentation for any programming library
  - **claude-md-management** — Maintains project instruction files that teach Claude about your codebase
- **A statusline** that shows useful info (current folder, git branch, model, context usage) while you work
- **Safety rails** — Claude can read, edit, and run code, but can't access your passwords, delete your hard drive, or overwrite other people's work
- **Sandbox mode** — An extra security layer that restricts commands to your project files, so you don't get interrupted with permission prompts
- **Auto-memory** — Claude remembers your preferences and project context between conversations
- **Docker** — Colima (macOS) or Docker Desktop (Windows) for running containers
- **Optional tools** — The script offers to install Ghostty, Chrome, VS Code, and useful Chrome extensions

### Why these defaults?

Out of the box, Claude Code asks permission for every command it runs (besides editing files). This configuration pre-approves safe commands so you can focus on the work instead of clicking "allow" repeatedly — while still blocking anything dangerous.

- **Allowed commands** cover everyday development tasks (file operations, git, build tools)
- **Denied commands** prevent catastrophic mistakes (deleting your hard drive, force-pushing, etc.)
- **Sandbox** restricts even allowed commands to only touch your project files
- **Docker** runs outside the sandbox because it needs access to the Docker socket (`/var/run/docker.sock`), which is allowlisted
- **Web requests** are allowed to all websites — the sandbox does not restrict by domain. See [sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) for a more restrictive option.

The goal is to do all cowork and coding work within the Claude desktop app. At this time, Claude Code settings (permissions, plugins, sandbox) must be managed through the CLI. To do remote work from the Claude mobile app, run `claude remote-control` from the terminal in the folder you want to work. You can also connect your GitHub account to Claude to work on any repository directly from mobile without a running terminal.

For a detailed explanation of every setting, see [`settings/code-settings-explainer.md`](settings/code-settings-explainer.md).

---

## What's Included

### Settings Files (`settings/`)

| File | Purpose | Destination |
|------|---------|-------------|
| `claude-code-settings.json` | CLI permissions, enabled plugins, auto-memory, sandbox | `~/.claude/settings.json` |
| `claude_desktop_config.json` | Claude desktop app preferences (quick entry shortcut, scheduled tasks, etc.) | `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows) |
| `code-settings-explainer.md` | Plain-language guide to every setting in `claude-code-settings.json` | Reference only (not copied) |
| `example-CLAUDE.md` | Example project-level CLAUDE.md | Place in any project root |

### Scripts (`scripts/`)

| File | Platform | What it does |
|------|----------|--------------|
| `setup-mac.sh` | macOS | Installs Claude app + CLI, copies settings, offers optional tools |
| `setup-windows.ps1` | Windows | Installs Claude app + CLI, copies settings, offers optional tools |

## Installed Plugins (Claude Code CLI)

These plugins are installed from the official `anthropics/claude-plugins-official` marketplace:

1. **superpowers** - Skills framework (brainstorming, TDD, debugging, planning, etc.)
2. **frontend-design** - Production-grade frontend/UI design assistance
3. **context7** - Live documentation lookup for any library
4. **claude-md-management** - CLAUDE.md file auditing and maintenance

## Optional Third-Party Tools

The setup scripts will prompt you (Y/n) to install each of the following:

| Tool | macOS | Windows |
|------|-------|---------|
| Docker | Colima + Docker CLI (`brew install colima docker`) | Docker Desktop (`winget install Docker.DockerDesktop`) |
| Ghostty terminal | `brew install --cask ghostty` | N/A (macOS/Linux only) |
| Google Chrome | `brew install --cask google-chrome` | `winget install Google.Chrome` |
| Claude Chrome extension | Opens Chrome Web Store page | Opens Chrome Web Store page |
| Markdown Viewer Chrome extension | Opens Chrome Web Store page | Opens Chrome Web Store page |
| Visual Studio Code | `brew install --cask visual-studio-code` | `winget install Microsoft.VisualStudioCode` |
| VS Code CLI (`code` command) | Symlinks to `/usr/local/bin` | Adds to user PATH |

All optional tools are skipped if already installed. Chrome extensions require Chrome to be installed first.

## Desktop App Preferences

- Quick Entry shortcut: `Alt+Space`
- Dock bounce notifications: enabled
- Keep awake: enabled
- Scheduled tasks: enabled (both Cowork and CCD)
- Web search in Cowork: enabled

## CLI Permissions Overview

The settings include a curated permission set:

**Allowed:**
- All file operations (Read, Edit, Write, Glob, Grep)
- Common bash commands (ls, find, cat, echo, mkdir, cp, mv, grep, sed, etc.)
- Git operations (status, log, diff, branch, checkout, add, commit, push)
- Dev tools (npm, npx, node, python, pip, cargo, rustc, docker)
- Web access (WebFetch)
- All MCP tools for Context7 plugin

**Denied (safety rails):**
- Reading .env and secrets files
- Destructive commands (rm -rf /, sudo, dd, mkfs, shutdown, reboot)
- Dangerous git operations (reset --hard, push --force)
- AWS IAM deletions, CDK destroy
