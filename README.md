# Dotfiles

macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/). The source state lives in [`chezmoi/`](chezmoi) (see `.chezmoiroot`).

## Getting Started

```shell
env ASK=1 sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/nijicha/dotfiles.git
```

## Scripts

All scripts are bash and run with macOS's built-in `/bin/bash`, so they work on a fresh Mac.

| Command | What it does |
| --- | --- |
| `./bin/setup` | Install Xcode CLI tools, Homebrew, and every package in the Homebrew/MAS lists. `AUTO=true` also opens download pages for manual apps. |
| `./bin/backup` | Pull current configs, Homebrew/MAS lists, manually installed apps, and selected fonts back into the chezmoi source. |
| `./bin/unused` | List apps in `/Applications` that aren't tracked by any list. |
| `./bin/validate` | Syntax-check the scripts and shell configs, validate Claude settings JSON, and run `chezmoi verify`. |
