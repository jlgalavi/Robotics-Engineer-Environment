#!/usr/bin/env bash
# Small, conservative aliases for everyday Linux commands.

# Directory listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Human-readable disk usage
alias df='df -h'
alias du='du -h'

# Search
alias grep='grep --color=auto'

# Clear terminal with an explicit command.
alias cls='clear'

# Use colored ls output when GNU dircolors is available.
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi