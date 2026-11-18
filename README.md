# Dotfiles

macOS dotfiles managed by [chezmoi](https://www.chezmoi.io/). The source state lives in [`chezmoi/`](chezmoi) (see `.chezmoiroot`).

## Getting Started

Some files are age-encrypted (see [Encryption](#encryption)), so restore the key before the first apply:

```shell
# 1. Restore the age identity from 1Password ("chezmoi age key") to ~/.config/chezmoi/key.txt
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
# paste the key into ~/.config/chezmoi/key.txt, then: chmod 600 ~/.config/chezmoi/key.txt

# 2. Init and apply
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

## Encryption

This repo is public. Files that may hold secrets or can't be redistributed are stored with chezmoi's built-in [age](https://age-encryption.org) encryption (`encrypted_*.age` in the source):

- App exports: Raycast `.rayconfig`, iStat Menus `.ismp7`, iTerm2 `.plist` and `.itermexport`
- Fonts without a redistribution license (everything except LINESeed and Chonburi, which are SIL OFL)

The public recipient is in `chezmoi/.chezmoi.yaml.tmpl`. The private identity lives only in `~/.config/chezmoi/key.txt` and 1Password; losing both means losing these files.

- `chezmoi add --encrypt <file>` to add a new sensitive file.
- `./bin/backup` keeps existing files encrypted (`chezmoi re-add`), and adds new app exports and non-OFL fonts encrypted.
- `./bin/validate` fails if an app export is stored in plain text or a private key lands in the repo.
