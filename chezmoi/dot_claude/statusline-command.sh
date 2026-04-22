#!/bin/sh
# Claude Code status line - powerline style matching Starship prompt

input=$(cat)
ESC=$(printf '\033')

# Extract fields from JSON input
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Color codes (truecolor)
R="${ESC}[0m"                        # reset
PURPLE_BG="${ESC}[48;2;154;52;142m"
PURPLE_FG="${ESC}[38;2;154;52;142m"
PINK_BG="${ESC}[48;2;218;98;125m"
PINK_FG="${ESC}[38;2;218;98;125m"
ORANGE_BG="${ESC}[48;2;252;161;125m"
ORANGE_FG="${ESC}[38;2;252;161;125m"
BLUE_BG="${ESC}[48;2;134;187;216m"
BLUE_FG="${ESC}[38;2;134;187;216m"
TEAL_BG="${ESC}[48;2;6;150;154m"
TEAL_FG="${ESC}[38;2;6;150;154m"
WHITE_FG="${ESC}[38;2;255;255;255m"
DARK_FG="${ESC}[38;2;40;40;40m"
SEP=$(printf '\xee\x82\xb0')  # powerline right chevron U+E0B0

# Username (always shown)
seg_user=" ${USER:-$(id -un)} "

# Project name (from git remote origin, fallback to directory name)
seg_project=""
seg_git=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  # Project name: extract org/repo or repo from remote URL
  remote_url=$(git -C "$cwd" remote get-url origin 2>/dev/null)
  if [ -n "$remote_url" ]; then
    # Strip .git suffix, then extract org/repo from URL
    project=$(echo "$remote_url" | sed 's/\.git$//' | sed 's|.*github\.com[:/]||' | sed 's|.*gitlab\.com[:/]||' | sed 's|.*bitbucket\.org[:/]||')
  fi
  # Fallback to top-level directory name
  if [ -z "$project" ]; then
    toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
    project=$(basename "$toplevel" 2>/dev/null)
  fi
  if [ -n "$project" ]; then
    seg_project=" ${project} "
  fi

  # Git branch + PR number
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ ${#branch} -gt 11 ]; then
      branch="${branch:0:11}⋯"
    fi
    git_dirty=""
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      git_dirty=" !"
    fi
    # PR number with file cache (refreshes every 5 min to avoid API latency)
    pr_num=""
    if command -v gh > /dev/null 2>&1; then
      cache_dir="${TMPDIR:-/tmp}/claude-statusline"
      toplevel=${toplevel:-$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)}
      cache_key=$(echo "${toplevel}:${branch}" | sed 's|/|_|g')
      cache_file="${cache_dir}/${cache_key}"
      mkdir -p "$cache_dir" 2>/dev/null
      # Use cache if < 5 min old
      if [ -f "$cache_file" ] && [ "$(find "$cache_file" -mmin -5 2>/dev/null)" ]; then
        pr_num=$(cat "$cache_file")
      else
        pr_num=$(gh pr view --json number -q .number 2>/dev/null || true)
        printf '%s' "$pr_num" > "$cache_file" 2>/dev/null
      fi
    fi
    pr_info=""
    if [ -n "$pr_num" ]; then
      pr_info=" #${pr_num}"
    fi
    seg_git="  ${branch}${pr_info}${git_dirty} "
  fi
elif [ -n "$cwd" ]; then
  # Not a git repo — show directory name
  seg_project=" $(basename "$cwd") "
fi

# Model (shorten "Claude Sonnet 4.6" → "Sonnet 4.6")
seg_model=""
if [ -n "$model" ]; then
  short_model=$(echo "$model" | sed 's/^Claude //')
  seg_model=" ${short_model} "
fi

# Context usage
seg_ctx=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  seg_ctx=" ♥ ${used_int}% "
fi

# Output segments with powerline chevrons
# Each transition: prev_fg + next_bg + SEP, then next_bg + text_fg + text

prev_fg="$PURPLE_FG"

# 1. Username (purple)
printf '%s' "${PURPLE_BG}${DARK_FG}${seg_user}${R}"

# 2. Project name (pink)
if [ -n "$seg_project" ]; then
  printf '%s' "${PURPLE_FG}${PINK_BG}${SEP}${R}${PINK_BG}${DARK_FG}${seg_project}${R}"
  prev_fg="$PINK_FG"
fi

# 3. Git branch (orange)
if [ -n "$seg_git" ]; then
  printf '%s' "${prev_fg}${ORANGE_BG}${SEP}${R}${ORANGE_BG}${DARK_FG}${seg_git}${R}"
  prev_fg="$ORANGE_FG"
fi

# 4. Model (blue)
if [ -n "$seg_model" ]; then
  printf '%s' "${prev_fg}${BLUE_BG}${SEP}${R}${BLUE_BG}${DARK_FG}${seg_model}${R}"
  prev_fg="$BLUE_FG"
fi

# 5. Context (teal)
if [ -n "$seg_ctx" ]; then
  printf '%s' "${prev_fg}${TEAL_BG}${SEP}${R}${TEAL_BG}${WHITE_FG}${seg_ctx}${R}"
  prev_fg="$TEAL_FG"
fi

# Trailing chevron to close last segment
printf '%s' "${prev_fg}${SEP}${R}"

echo ""
