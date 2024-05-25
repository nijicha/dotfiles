dotfiles
---

> dotfiles managed by [chezmoi](https://chezmoi.io)

## Pre-requisites
- Homebrew should be installed
- `curl` or `wget` should be installed
- Install `chezmoi` (brew install chezmoi)
- Install `git-delta` (brew install git-delta)
- Install `1Password` (brew install --cask 1password)
- Enable 1Password SSH Agent for SSH `git clone`

## Usage
1. Clone this repository `git clone git@github.com:nijicha/dotfiles.git ~/.dotfiles`
2. Copy chezmoi config `cp -r ~/.dotfiles/chezmoi/ ~/.local/share/chezmoi`
3. Run `chezmoi init`
4. Run `chezmoi apply -v`
5. `git-delta` will be show as chezmoi diff verbose check it all and apply

## Manual
- [ ] Enable 1Password SSH Agent
- [ ] Install Jetbrains IDE from Toolbox
- [ ] Run brew services `formula` as needed (Like redis)

## TODO
- [ ] Add Brewfile required by `brew bundle`
- [ ] Add 1password-cli integration
- [ ] Add age | gpg encryption
- [ ] More Config chezmoi https://github.com/twpayne/chezmoi
- [ ] Add .plist of some apps
- [ ] Update remote install shell script be usable

    ```shell
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/nijicha/dotfiles/master/bin/remote_install.sh) -v"
    ```
