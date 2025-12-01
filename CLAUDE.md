# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi-managed dotfiles repository for macOS system configuration. The repository manages system configurations, application settings, shell configurations, and tracks installed applications via Homebrew, Mac App Store, and manual installations.

## Repository Structure

```
.
├── bin/                    # Management scripts
│   ├── setup              # Initial system setup (Bash)
│   ├── backup             # Backup configurations and apps (Fish)
│   └── unused             # List unmanaged applications (Fish)
├── chezmoi/               # Chezmoi source directory (actual dotfiles)
│   ├── .chezmoi.yaml.tmpl            # Chezmoi configuration template
│   ├── dot_gitconfig.tmpl            # Git configuration template
│   ├── dot_gitignore_global          # Global git ignore
│   ├── dot_config/                   # XDG config files
│   │   ├── ghostty/                  # Ghostty terminal config
│   │   ├── mise/                     # Mise version manager config
│   │   ├── private_fish/             # Fish shell config
│   │   │   └── config.fish.tmpl
│   │   └── starship.toml             # Starship prompt config
│   ├── dot_application-config/       # Application settings
│   │   ├── homebrew/                 # Package lists
│   │   │   ├── brew-formula.txt      # Homebrew formulae
│   │   │   ├── brew-casks.txt        # Homebrew casks
│   │   │   └── mas-list.txt          # Mac App Store apps
│   │   ├── manual_apps.yml           # Manually installed apps
│   │   ├── jetbrains/
│   │   ├── iterm2/
│   │   ├── rectangle/
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

# Validate chezmoi configuration
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

- **`.chezmoiroot`**: Points to `./chezmoi` subdirectory (not the repository root)
- **Template files** (`.tmpl` extension): Use Go templating with variables defined in `.chezmoi.yaml.tmpl`
- **Data variables**: `name`, `email`, `github_user`, `signing_key` can be prompted during initial setup with `ASK=1` environment variable
- **Prefixes**:
  - `dot_` → `.` (hidden files)
  - `private_` → restricted permissions
  - Combinations like `private_dot_` work too

### Application Management Strategy

The repository tracks three types of applications:

1. **Homebrew Formulae** (`brew-formula.txt`): CLI tools installed via `brew install`
2. **Homebrew Casks** (`brew-casks.txt`): GUI apps installed via `brew install --cask`
3. **Mac App Store** (`mas-list.txt`): Apps installed via `mas` (format: `ID Name (Version)`)
4. **Manual Apps** (`manual_apps.yml`): Apps installed manually, tracked for documentation

### Script Responsibilities

**`bin/setup`** (Bash):
- Installs Xcode Command Line Tools
- Ensures Homebrew is installed
- Reads package lists and installs missing packages
- Shows spinners during installation with ✅/❌ status
- Supports `AUTO=true` environment variable to open manual app download URLs
- Uses optimized batch checking (fetches all installed packages once)

**`bin/backup`** (Fish):
- Backs up configs: `~/.config/ghostty/`, `~/.config/mise/`, `~/.config/starship.toml`
- Backs up `~/.application-config/`
- Generates fresh Homebrew package lists using `brew leaves`, `brew list --cask`, `mas list`
- Detects manually installed apps by comparing `/Applications/*.app` against managed lists
- Backs up specific fonts matching patterns: LINESeed, Chonburi, CooperBlack, LEMONMILK, etc.
- Preserves existing URLs and notes in `manual_apps.yml` when regenerating

**`bin/unused`** (Fish):
- Lists applications in `/Applications` not tracked by any management system
- Filters out macOS system apps
- Handles special cases (e.g., JetBrains apps managed by jetbrains-toolbox)
- Uses normalization for fuzzy matching between cask names and app names

### Security Considerations

- **Git signing**: Configured to use 1Password SSH signing (`op-ssh-sign`)
- **File permissions**: `private_` prefix ensures restrictive permissions on sensitive files
- **URL validation**: Setup script only allows `http://` and `https://` URLs for manual apps
- **Temp file security**: Backup script sets `chmod 600` on temporary files

### Shell Configuration

- **Primary shell**: Fish shell
- **Prompt**: Starship
- **Version manager**: Mise (replaces asdf/mise)
- **Terminal**: Ghostty (with iterm2 fallback)
- **Pager**: Delta (for git diffs)
- **Editor**: VSCode for chezmoi (`code --wait`), vim for git

## Important Notes

- The actual dotfiles are in `./chezmoi/`, not the repository root (due to `.chezmoiroot`)
- Package lists are auto-generated by `./bin/backup` - don't manually edit unless necessary
- `brew leaves` is used (not `brew list`) to only track top-level formulae, not dependencies
- Font backup only tracks specific font families (see `font_names` in backup script)
- Manual apps file preserves existing URLs/notes across regeneration
