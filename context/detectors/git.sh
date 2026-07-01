#!/usr/bin/env bash
# Read-only Git repository detection.
# Detector result variables are consumed by context/rde-context.
# shellcheck disable=SC2034

__rde_context_detect_git() {
    local root branch
    RDE_GIT_DETECTED=false
    RDE_GIT_ROOT=''
    RDE_GIT_BRANCH=''
    RDE_GIT_DIRTY=false

    command -v git >/dev/null 2>&1 || return 0
    if ! root=$(git rev-parse --show-toplevel 2>/dev/null); then
        return 0
    fi

    RDE_GIT_DETECTED=true
    RDE_GIT_ROOT=$root
    if branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
        RDE_GIT_BRANCH=$branch
    else
        RDE_GIT_BRANCH=$(git rev-parse --short HEAD 2>/dev/null || printf 'detached')
    fi

    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        RDE_GIT_DIRTY=true
    fi
}
