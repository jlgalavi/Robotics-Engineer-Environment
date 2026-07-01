#!/usr/bin/env bash
# Explicit ROS 2 environment activation helpers.

srcros() {
    local setup="/opt/ros/${RDE_ROS_DISTRO:-jazzy}/setup.bash"

    if [[ ! -r "$setup" ]]; then
        printf 'ROS 2 setup not found: %s\n' "$setup" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$setup"
    printf 'ROS 2 %s environment loaded.\n' "${RDE_ROS_DISTRO:-jazzy}"
}

srcws() {
    local root setup
    if ! root="$(__rde_ros2_find_ws_root)"; then
        printf 'ROS 2 workspace not found from: %s\n' "$PWD" >&2
        return 1
    fi

    setup="$root/install/setup.bash"
    if [[ ! -r "$setup" ]]; then
        printf 'Workspace setup not found: %s\n' "$setup" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$setup"
    printf 'Workspace sourced: %s\n' "$root"
}
