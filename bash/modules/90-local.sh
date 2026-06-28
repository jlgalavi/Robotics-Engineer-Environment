#!/usr/bin/env bash
# Load user-specific configuration last so it can override all defaults.
# The repository never creates or manages this file.

LOCAL_CONFIG="${HOME}/.rde.local"

if [[ "${RDE_SKIP_LOCAL_CONFIG:-false}" != "true" && -r "$LOCAL_CONFIG" ]]; then
    source "$LOCAL_CONFIG"
fi

unset LOCAL_CONFIG
