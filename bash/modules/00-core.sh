#!/usr/bin/env bash
# Core interactive-shell behavior and optional system integrations.

# Only run in interactive shells.
case $- in
    *i*) ;;
    *) return ;;
esac

# Keep terminal dimensions current after each command.
shopt -s checkwinsize

# Load Bash completion when available.
if ! shopt -oq posix; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# Enable FZF key bindings when installed.
if [[ -r /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
fi