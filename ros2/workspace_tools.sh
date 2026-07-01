#!/usr/bin/env bash
# ROS 2 workspace discovery and navigation.

__rde_ros2_find_ws_root() {
    local candidate="$PWD"

    while :; do
        if [[ -f "$candidate/install/setup.bash" ||
              -d "$candidate/src" ||
              -f "$candidate/colcon.meta" ||
              ( -d "$candidate/build" && -d "$candidate/install" && -d "$candidate/log" ) ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi

        [[ "$candidate" == / ]] && return 1
        candidate="${candidate%/*}"
        [[ -n "$candidate" ]] || candidate=/
    done
}

wsroot() {
    local root
    if ! root="$(__rde_ros2_find_ws_root)"; then
        printf 'ROS 2 workspace not found from: %s\n' "$PWD" >&2
        return 1
    fi

    printf '%s\n' "$root"
}

wscd() {
    local root
    if ! root="$(__rde_ros2_find_ws_root)"; then
        printf 'ROS 2 workspace not found from: %s\n' "$PWD" >&2
        return 1
    fi

    cd -- "$root" || return
}
