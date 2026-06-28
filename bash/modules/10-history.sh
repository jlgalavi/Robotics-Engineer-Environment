#!/usr/bin/env bash
# Predictable shell history shared across terminal tabs.

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=20000
HISTFILESIZE=50000

shopt -s histappend

# Persist history immediately and reload commands from other open shells.
# Avoid adding the hook more than once when bash/bashrc is sourced repeatedly.
_rde_history_sync() {
    history -a
    history -c
    history -r
}

if [[ ";${PROMPT_COMMAND:-};" != *';_rde_history_sync;'* ]]; then
    PROMPT_COMMAND="_rde_history_sync${PROMPT_COMMAND:+; ${PROMPT_COMMAND}}"
fi
