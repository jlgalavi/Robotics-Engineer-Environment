#!/usr/bin/env bash
# Small shell utilities for everyday development.

mkcd() {
    if [[ $# -ne 1 ]]; then
        printf 'Usage: mkcd <directory>\n' >&2
        return 2
    fi

    mkdir -p "$1" && cd "$1" || return
}

hist() {
    if [[ $# -eq 0 ]]; then
        history
    else
        history | grep --color=auto "$@"
    fi
}

path() {
    printf '%s\n' "${PATH//:/$'\n'}"
}

ports() {
    ss -tulpen
}

myip() {
    hostname -I | awk '{print $1}'
}

extract() {
    if [[ $# -ne 1 ]]; then
        printf 'Usage: extract <archive>\n' >&2
        return 2
    fi

    if [[ ! -f "$1" ]]; then
        printf 'File not found: %s\n' "$1" >&2
        return 1
    fi

    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.tar.xz) tar xJf "$1" ;;
        *.tar) tar xf "$1" ;;
        *.zip) unzip "$1" ;;
        *.7z) 7z x "$1" ;;
        *) printf 'Unsupported archive: %s\n' "$1" >&2; return 2 ;;
    esac
}