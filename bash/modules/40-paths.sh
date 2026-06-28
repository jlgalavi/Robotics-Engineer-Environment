#!/usr/bin/env bash
# Configure executable search paths.

# Add a directory only when it exists and is not already in PATH. This keeps
# repeated `source bash/bashrc` tests from growing PATH indefinitely.
_rde_prepend_path() {
    [[ -d "$1" ]] || return 0
    [[ ":${PATH}:" == *":$1:"* ]] || PATH="$1:$PATH"
}

# User binaries.
_rde_prepend_path "$HOME/.local/bin"

# Repository scripts.
if [[ -n "${REE_ROOT:-}" && -d "$REE_ROOT/scripts" ]]; then
    _rde_prepend_path "$REE_ROOT/scripts"
fi

export PATH
unset -f _rde_prepend_path
