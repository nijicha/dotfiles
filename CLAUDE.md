# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi-managed dotfiles repository for macOS system configuration. The repository manages system configurations, application settings, shell configurations, and tracks installed applications via Homebrew, Mac App Store, and manual installations.

## Repository Structure

```
.
├── bin/                    # Management scripts (bash, macOS stock /bin/bash 3.2 compatible)
│   ├── setup               # Initial system setup
│   ├── backup              # Backup configurations and apps
│   ├── unused              # List unmanaged applications
│   └── validate            # Syntax/JSON checks + chezmoi verify
├── chezmoi/                # Chezmoi source directory (actual dotfiles)
│   ├── .chezmoi.yaml.tmpl            # Chezmoi configuration template
│   ├── .chezmoiignore                # Ignore rules (target paths relative to $HOME)
│   ├── dot_gitconfig.tmpl            # Git configuration template
│   ├── dot_gitignore_global          # Global git ignore
│   ├── dot_zshenv                    # Env/PATH for every zsh (incl. non-interactive)
│   ├── dot_zshrc.tmpl                # Interactive zsh config
│   ├── dot_config/                   # XDG config files
│   │   ├── mise/                     # Mise version manager config
│   │   └── starship.toml             # Starship prompt config
│   ├── private_dot_claude/           # Claude Code user settings (~/.claude, mode 700)
│   │   ├── settings.json
│   │   └── statusline-command.sh
│   ├── dot_application-config/       # Application settings
│   │   ├── homebrew/                 # Package lists
│   │   │   ├── brew-formula.txt      # Homebrew formulae
│   │   │   ├── brew-casks.txt        # Homebrew casks
│   │   │   └── mas-list.txt          # Mac App Store apps
│   │   ├── manual_apps.yml           # Manually installed apps
│   │   ├── jetbrains/
│   │   ├── iterm2/
│   │   ├── rectangle/
│   │   ├── iStat Menus Settings.ismp7
│   │   └── Raycast *.rayconfig
│   └── private_Library/              # macOS Library files (fonts, etc.)
└── .chezmoiroot                      # Points to ./chezmoi
```

## Key Commands

### Initial Installation
```bash
# Install chezmoi and apply dotfiles (from GitHub)
env ASK=1 sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/nijicha/dotfiles.git
```

### Development Commands

```bash
# Setup system (installs Xcode CLI tools, Homebrew, packages, apps)
./bin/setup

# Backup current configurations and application lists
./bin/backup

# List unused/unmanaged applications
./bin/unused

# Syntax-check scripts and shell configs, validate settings JSON, run chezmoi verify
./bin/validate
```

### Chezmoi Operations

```bash
# Apply changes from source to target
chezmoi apply

# Edit a managed file
chezmoi edit <file>

# Check what would change
chezmoi diff

# Add a new file to be managed
chezmoi add <file>

# Get the source path for a managed file
chezmoi source-path <file>

# Re-run templates
chezmoi apply --force
```

## Architecture and Design

### Chezmoi Configuration System

This repository uses chezmoi's templating system for personalization:

- **`.chezmoiroot`**: Points to `./chezmoi` subdirectory (not the repository root). chezmoi special files (`.chezmoiignore`, `.chezmoi.yaml.tmpl`, …) must live in `chezmoi/`, not the repo root.
- **`.chezmoiignore`**: Patterns match target paths relative to `$HOME` (no `~/`), and only affect files that exist in the source state.
- **Template files** (`.tmpl` extension): Use Go templating with variables defined in `.chezmoi.yaml.tmpl`
- **Data variables**: `name`, `email`, `github_user`, `signing_key` can be prompted during initial setup with `ASK=1` environment variable. The template keeps values already in `~/.config/chezmoi/chezmoi.yaml`, so re-running `chezmoi init` doesn't reset them to the defaults. Default email is the GitHub noreply address.
- **Prefixes**:
  - `dot_` → `.` (hidden files)
  - `private_` → restricted permissions
  - Combinations like `private_dot_` work too

### Application Management Strategy

The repository tracks four types of applications:

1. **Homebrew Formulae** (`brew-formula.txt`): CLI tools installed via `brew install`
2. **Homebrew Casks** (`brew-casks.txt`): GUI apps installed via `brew install --cask`
3. **Mac App Store** (`mas-list.txt`): Apps installed via `mas` (format: `ID Name (Version)`)
4. **Manual Apps** (`manual_apps.yml`): Apps installed manually, tracked for documentation

### Script Responsibilities

All scripts are bash and must stay compatible with macOS's stock bash 3.2 (no associative arrays, no `mapfile`, no `${var,,}`) so they run on a fresh Mac before Homebrew is installed.

**`bin/setup`**:
- Installs Xcode Command Line Tools
- Ensures Homebrew is installed
- Reads package lists and installs missing packages
- Shows spinners during installation with ✅/❌ status
- Supports `AUTO=true` environment variable to open manual app download URLs
- Uses optimized batch checking (fetches all installed packages once)

**`bin/backup`**:
- Backs up configs: `~/.config/mise/`, `~/.config/starship.toml`, `~/.claude/settings.json` (skipped if it looks like it contains secrets)
- Backs up `~/.application-config/`
- Generates fresh Homebrew package lists using `brew leaves`, `brew list --cask`, `mas list`
- Detects manually installed apps by comparing `/Applications/*.app` against managed lists
- Backs up specific fonts matching patterns: LINESeed, Chonburi, CooperBlack, LEMONMILK, etc.
- Preserves existing URLs and notes in `manual_apps.yml` when regenerating
- Uses `chezmoi re-add` for `~/.application-config` so encrypted files stay encrypted; new app exports are added with `--encrypt`
- Fonts outside `OPEN_FONTS` (SIL OFL families) are added with `--encrypt`
- Can be sourced (`source bin/backup`) to load its functions without running a backup; `MANUAL_APPS_FILE` overrides the output path for testing

**`bin/unused`**:
- Lists applications in `/Applications` not tracked by any management system
- Filters out macOS system apps
- Handles special cases (e.g., JetBrains apps managed by jetbrains-toolbox)
- Uses normalization for fuzzy matching between cask names and app names

**`bin/validate`**:
- `bash -n` on every `bin/` script, `zsh -n` on the rendered `~/.zshrc` and `~/.zshenv`
- `jq empty` on the Claude settings JSON
- `chezmoi verify` (fails if the home directory differs from the source state)
- App exports under `dot_application-config/` are encrypted (allowlist: homebrew/, jetbrains/, rectangle/, manual_apps.yml)
- No age private key anywhere in the repo

### Security Considerations

- **Git signing**: Configured to use 1Password SSH signing (`op-ssh-sign`)
- **File permissions**: `private_` prefix ensures restrictive permissions on sensitive files (e.g. `~/.claude` stays 700)
- **URL validation**: Setup script only allows `http://` and `https://` URLs for manual apps
- **Temp file security**: Backup script sets `chmod 600` on temporary files
- **Public repo + age encryption**: The GitHub repo is public. App exports (Raycast, iStat Menus, iTerm2) and non-OFL fonts are stored as `encrypted_*.age` using chezmoi's built-in age. Recipient is in `.chezmoi.yaml.tmpl`; the identity is `~/.config/chezmoi/key.txt` (backed up in 1Password) and must never be committed. Never `chezmoi add` an encrypted target without `--encrypt` (use `chezmoi re-add`), or it is stored in plain text.
- **Claude settings**: `permissions.deny` blocks reading `.env*`, `.dev.vars`, `application.yml` and running `wrangler`/`doctl`. Project-specific `autoMode` context belongs in that project's `.claude/settings.local.json`, not the global settings.

### Shell Configuration

- **Primary shell**: zsh (Homebrew `/opt/homebrew/bin/zsh`), with zsh-autosuggestions and zsh-syntax-highlighting (must stay the last thing sourced in `.zshrc`)
- **Prompt**: Starship
- **Version manager**: Mise (shims on PATH in `.zshenv` for non-interactive shells)
- **Terminal**: iTerm2
- **Pager**: Delta (for git diffs and `chezmoi diff`)
- **Editor**: VSCode for chezmoi (`code --wait`), vim for git

## Important Notes

- The actual dotfiles are in `./chezmoi/`, not the repository root (due to `.chezmoiroot`)
- Package lists are auto-generated by `./bin/backup` - don't manually edit unless necessary
- `brew leaves` is used (not `brew list`) to only track top-level formulae, not dependencies
- Font backup only tracks specific font families (see `FONT_NAMES` in backup script)
- Manual apps file preserves existing URLs/notes across regeneration
- `dot_zshrc.tmpl` is a template, so don't `chezmoi add ~/.zshrc` (it would overwrite the template); edit the source instead
- Tools like Docker Desktop, Orca, and Impeccable write into `~/.zshrc` / `~/.claude/settings.json`; review `chezmoi diff` before `chezmoi apply` so their changes aren't silently dropped
