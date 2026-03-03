#!/bin/sh
# Claude Code status line - inspired by Starship prompt configuration

input=$(cat)

# Extract fields from JSON input
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: shorten like Starship (truncation_length=2, home_symbol=⌂)
home="$HOME"
if [ -n "$cwd" ]; then
  # Replace home prefix with ⌂
  short_dir=$(echo "$cwd" | sed "s|^$home|⌂|")
  # Truncate to last 2 path components (keeping leading ⌂ if present)
  dir_display=$(echo "$short_dir" | awk -F'/' '{
    n=NF;
    if (NF <= 2) { print $0 }
    else {
      result = $NF; prev = $(NF-1);
      if (prev != "") result = prev "/" result;
      print "□ " result
    }
  }')
else
  dir_display=""
fi

# Git branch (skip optional lock)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ "$branch" != "main" ] && [ "$branch" != "master" ]; then
    # Truncate to 11 chars like Starship
    if [ ${#branch} -gt 11 ]; then
      branch="${branch:0:11}⋯"
    fi
    git_branch=" △ $branch"
  fi
fi

# Context usage indicator
ctx_info=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  ctx_info=" ◄ ctx:${used_int}%"
fi

# Build status line using printf for color support
printf "\033[1;34m%s\033[0m" "$dir_display"
if [ -n "$git_branch" ]; then
  printf "\033[1;94m%s\033[0m" "$git_branch"
fi
if [ -n "$model" ]; then
  printf "\033[2;37m  %s\033[0m" "$model"
fi
if [ -n "$ctx_info" ]; then
  printf "\033[2;37m%s\033[0m" "$ctx_info"
fi
echo ""
