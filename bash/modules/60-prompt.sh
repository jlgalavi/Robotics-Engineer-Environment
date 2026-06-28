#!/usr/bin/env bash
# Compact and configurable prompt.

# Use the current account name by default; ~/.rde.local may choose a label.
RDE_PROMPT_USER="${RDE_PROMPT_USER:-${USER:-user}}"
RDE_PROMPT_SHOW_HOST="${RDE_PROMPT_SHOW_HOST:-false}"
RDE_PROMPT_SHOW_GIT="${RDE_PROMPT_SHOW_GIT:-true}"

__rde_prompt_identity() {
    if [[ "$RDE_PROMPT_SHOW_HOST" == "true" ]]; then
        printf '%s@%s' "$RDE_PROMPT_USER" "${HOSTNAME%%.*}"
    else
        printf '%s' "$RDE_PROMPT_USER"
    fi
}

__rde_prompt_git() {
    [[ "$RDE_PROMPT_SHOW_GIT" == "true" ]] || return 0
    declare -F __rde_git_branch >/dev/null 2>&1 || return 0
    __rde_git_branch
}

if [[ "${TERM:-}" == *color* || "${TERM:-}" == *-256color ]]; then
    PS1='\[\e[1;32m\]$(__rde_prompt_identity)\[\e[0m\]:\[\e[1;34m\]\W\[\e[0;33m\]$(__rde_prompt_git)\[\e[0m\]\$ '
else
    PS1='$(__rde_prompt_identity):\W$(__rde_prompt_git)\$ '
fi
