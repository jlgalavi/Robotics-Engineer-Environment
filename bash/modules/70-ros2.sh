#!/usr/bin/env bash
# ROS 2 helpers.
# ROS is never sourced automatically. The user explicitly decides when to
# activate a ROS environment or a workspace.

# Default ROS 2 distribution.
RDE_ROS_DISTRO="${RDE_ROS_DISTRO:-jazzy}"

#
# Environment
#

srcros() {
    local setup="/opt/ros/${RDE_ROS_DISTRO}/setup.bash"

    if [[ -r "$setup" ]]; then
        source "$setup"
        printf 'ROS 2 %s environment loaded.\n' "$RDE_ROS_DISTRO"
    else
        printf 'ROS 2 setup not found: %s\n' "$setup" >&2
        return 1
    fi
}

srcws() {
    local setup="${PWD}/install/setup.bash"

    if [[ -r "$setup" ]]; then
        source "$setup"
        printf 'Workspace sourced: %s\n' "$PWD"
    else
        printf 'Workspace setup not found: %s\n' "$setup" >&2
        return 1
    fi
}

#
# Build helpers
#

cb() {
    command -v colcon >/dev/null 2>&1 || {
        printf 'colcon is not installed or is not in PATH.\n' >&2
        return 127
    }

    colcon build --symlink-install "$@"
}

cbs() {
    if [[ $# -lt 1 ]]; then
        printf 'Usage: cbs <package_name> [colcon options...]\n' >&2
        return 2
    fi

    command -v colcon >/dev/null 2>&1 || {
        printf 'colcon is not installed or is not in PATH.\n' >&2
        return 127
    }

    local package="$1"
    shift

    colcon build \
        --symlink-install \
        --packages-select "$package" \
        "$@"
}

#
# ROS 2 inspection aliases
#

alias rn='ros2 node list'
alias rt='ros2 topic list'
alias rs='ros2 service list'
alias rp='ros2 param list'
alias ra='ros2 action list'
alias ri='ros2 interface list'