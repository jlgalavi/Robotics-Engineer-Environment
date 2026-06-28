#!/usr/bin/env bash
# Git aliases and lightweight Git status helpers.

# Basic Git aliases.
alias gst='git status --short --branch'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --decorate --graph -15'
alias gla='git log --oneline --decorate --graph --all -20'
alias gb='git branch'
alias gsw='git switch'
alias gco='git checkout'
alias gps='git push'
alias gpl='git pull'

# Prompt Git segment.
__rde_git_branch() {
    command -v git >/dev/null 2>&1 || return 0
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    local branch
    branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || \
        branch=$(git rev-parse --quiet --short HEAD 2>/dev/null) || return 0

    printf ' (%s)' "$branch"
}