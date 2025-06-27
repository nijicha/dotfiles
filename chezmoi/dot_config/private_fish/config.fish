if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval "$(/opt/homebrew/bin/brew shellenv)"

# Binary initialization
starship init fish | source

# Aliases
alias ls="eza --icons=always"
alias ll="eza --icons=always -l"
alias la="eza --icons=always -la"
alias tree="eza --icons=always --tree"
alias cat="bat"

# Personal aliases
alias ws="cd ~/workspace"
alias play="cd ~/playground"

export PATH="$PATH:$HOME/.local/bin"
