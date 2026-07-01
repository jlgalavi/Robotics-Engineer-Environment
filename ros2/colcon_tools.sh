#!/usr/bin/env bash
# ROS 2 colcon build and cleanup helpers.

__rde_ros2_colcon_build() {
    local use_symlinks=$1 usage=$2 root package=''
    local -a colcon_args=(build)
    shift 2

    if [[ ${1:-} == pkg ]]; then
        if [[ $# -lt 2 ]]; then
            printf 'Usage: %s\n' "$usage" >&2
            return 2
        fi
        package=$2
        shift 2
    fi

    command -v colcon >/dev/null 2>&1 || {
        printf 'colcon is not installed or is not in PATH.\n' >&2
        return 127
    }
    if ! root="$(__rde_ros2_find_ws_root)"; then
        printf 'ROS 2 workspace not found from: %s\n' "$PWD" >&2
        return 1
    fi

    if [[ $use_symlinks == true ]]; then
        colcon_args+=(--symlink-install)
    fi
    if [[ -n $package ]]; then
        colcon_args+=(--packages-select "$package")
    fi
    colcon_args+=("$@")

    (cd -- "$root" && colcon "${colcon_args[@]}")
}

wsbuild() {
    __rde_ros2_colcon_build false 'wsbuild [pkg <package_name>] [colcon options...]' "$@"
}

wsbuild_symlink() {
    __rde_ros2_colcon_build true 'wsbuild_symlink [pkg <package_name>] [colcon options...]' "$@"
}

wspkg() {
    if [[ $# -lt 1 ]]; then
        printf 'Usage: wspkg <package_name> [colcon options...]\n' >&2
        return 2
    fi
    __rde_ros2_colcon_build true \
        'wspkg <package_name> [colcon options...]' pkg "$@"
}

__rde_ros2_complete_build() {
    local command_name current
    COMPREPLY=()
    command_name=${COMP_WORDS[0]}
    current="${COMP_WORDS[COMP_CWORD]}"

    if [[ $command_name == wspkg && $COMP_CWORD -eq 1 ]] && \
        command -v ros2 >/dev/null 2>&1; then
        mapfile -t COMPREPLY < <(compgen -W "$(ros2 pkg list 2>/dev/null)" -- "$current")
    elif [[ $COMP_CWORD -eq 1 ]]; then
        mapfile -t COMPREPLY < <(compgen -W 'pkg' -- "$current")
    elif [[ $COMP_CWORD -eq 2 && ${COMP_WORDS[1]} == pkg ]] && \
        command -v ros2 >/dev/null 2>&1; then
        mapfile -t COMPREPLY < <(compgen -W "$(ros2 pkg list 2>/dev/null)" -- "$current")
    fi
}

complete -o default -F __rde_ros2_complete_build \
    wsbuild wsbuild_symlink wspkg cb cbs

wsclean() {
    local root reply
    if ! root="$(__rde_ros2_find_ws_root)"; then
        printf 'ROS 2 workspace not found from: %s\n' "$PWD" >&2
        return 1
    fi
    if [[ "$root" == / ]]; then
        printf 'Refusing to clean the filesystem root.\n' >&2
        return 1
    fi

    printf 'Remove build/, install/, and log/ from %s? [y/N] ' "$root"
    IFS= read -r reply
    case "$reply" in
        y|Y|yes|YES|Yes)
            rm -rf -- "$root/build" "$root/install" "$root/log"
            printf 'Workspace build artifacts removed: %s\n' "$root"
            ;;
        *)
            printf 'Cleanup cancelled.\n'
            return 1
            ;;
    esac
}
