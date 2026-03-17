# Claude Code Settings Explained

This is a plain-language guide to everything in `claude-code-settings.json` — the file that controls what Claude Code (the CLI tool) is allowed to do on your computer.

---

## Permissions

Permissions control what Claude can and can't do without asking you first. 

### What Claude is allowed to do

#### Read, edit, and create files

Claude can open any file in your project, make changes to it, or create new files. This is the core of what Claude Code does — it reads your code, understands it, and makes edits when you ask.

- **Read** — Open and look at any file
- **Edit / MultiEdit** — Change parts of a file (or multiple parts at once)
- **Write** — Create a new file or completely rewrite an existing one
- **Glob** — Search for files by name pattern (e.g., "find all `.js` files")
- **Grep** — Search for text inside files (e.g., "find everywhere that says `login`")
- **LS** — List what files and folders exist

#### Run common terminal commands

Claude can run everyday commands that developers use. These are grouped by purpose:

**Exploring files:**
`ls`, `pwd`, `find`, `cat`, `echo`, `head`, `tail`, `diff`, `grep`, `which`, `env`

These let Claude look around your project — list files, check paths, compare files, and find things.

**Organizing files:**
`mkdir`, `cp`, `mv`, `touch`, `rm`

These let Claude create folders, copy files, move files, and delete files. Deleting is allowed for normal cleanup (like removing a build folder), but mass-deletion is blocked (see "What Claude is NOT allowed to do" below).

**Working with Git (version control):**
`git status`, `git log`, `git diff`, `git branch`, `git checkout`, `git add`, `git commit`, `git push`

These let Claude check what's changed, create save points (commits), switch between branches, and upload code. This means Claude can manage your code history for you.

**Running code and build tools:**
`npm run`, `npx`, `node`, `python`, `pip`, `cargo`, `rustc`, `rustup`, `docker build`, `docker compose`

These let Claude run your project, install packages, build code, and work with containers. Covers JavaScript/TypeScript, Python, and Rust projects.

**Fetching web pages:**
`WebFetch`

Claude can fetch web pages to look up documentation, find solutions, or check references.

**Context7 plugin tools:**

Claude can use the Context7 plugin to look up live, up-to-date documentation for any programming library.

---

### What Claude is NOT allowed to do

These are safety rails — things that could cause serious damage if done accidentally.

#### Can't read your secrets

- `.env` files (where passwords and API keys are often stored)
- Anything in a `secrets/` folder

This prevents Claude from accidentally exposing sensitive information.

#### Can't run destructive system commands

- `rm -rf /` or `rm -rf *` — Would delete everything on your computer
- `rm ../*` — Would delete files outside your project
- `sudo` — Would run commands with full system access
- `dd` — Low-level disk writing tool that can overwrite drives
- `mkfs` — Formats (erases) entire disk drives
- `shutdown` / `reboot` — Would turn off or restart your computer

#### Can't do dangerous Git operations

- `git reset --hard` — Would permanently throw away uncommitted work
- `git push --force` / `git push -f` — Would overwrite other people's code on the server

#### Can't destroy cloud infrastructure

- `aws iam delete-*` — Would delete AWS security accounts/roles
- `npx cdk destroy` — Would tear down cloud infrastructure

### Adding new permissions as you work

You don't need to edit `claude-code-settings.json` by hand. If you're working on something and Claude needs a command that isn't in the allow list yet (e.g., `terraform`, `kubectl`, `pnpm`), just tell Claude to add it. Claude can edit the settings file directly. You'll need to restart Claude for the new permission to take effect.

---

## Plugins

Plugins extend what Claude can do. These four are enabled:

| Plugin | What it does |
|--------|-------------|
| **superpowers** | Adds structured workflows — brainstorming, test-driven development, debugging, planning, and code review |
| **frontend-design** | Helps Claude build polished, professional-looking web interfaces instead of generic-looking ones |
| **context7** | Lets Claude look up current documentation for any programming library (so it doesn't rely on potentially outdated knowledge) |
| **claude-md-management** | Helps maintain CLAUDE.md files — project instruction files that tell Claude about your codebase |

---

## Auto-Memory

```json
"autoMemoryEnabled": true
```

When turned on, Claude remembers things between conversations — your preferences, corrections you've made, and context about your project. This means you don't have to re-explain things every time you start a new chat.

---

## Sandbox

```json
"sandbox": {
  "enabled": true,
  "autoAllowBashIfSandboxed": true
}
```

The sandbox adds an extra layer of protection by limiting which files and network resources terminal commands can access. Even if a command is in the "allowed" list above, the sandbox restricts it to only touch files in your current project and approved system locations.

- **enabled** — The sandbox is active
- **autoAllowBashIfSandboxed** — Since the sandbox already provides protection, Claude doesn't need to ask permission before running each terminal command. This makes the experience faster and less interruptive while keeping you safe.
