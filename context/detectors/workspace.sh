#!/usr/bin/env bash
# Read-only ROS 2 workspace detection.
# Detector result variables are consumed by context/rde-context.
# shellcheck disable=SC2034

__rde_context_workspace_prefix_is_active() {
    local install=$1 prefixes

    for prefixes in \
        "${AMENT_PREFIX_PATH:-}" \
        "${COLCON_PREFIX_PATH:-}" \
        "${CMAKE_PREFIX_PATH:-}"; do
        if [[ ":$prefixes:" == *":$install:"* ]]; then
            return 0
        fi
    done

    return 1
}

__rde_context_detect_workspace() {
    local context_dir root install
    RDE_WS_DETECTED=false
    RDE_WS_ROOT=''
    RDE_WS_NAME=''
    RDE_WS_BUILT=false
    RDE_WS_SOURCED=false

    if ! declare -F __rde_ros2_find_ws_root >/dev/null 2>&1; then
        context_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
        # shellcheck disable=SC1091
        source "$context_dir/../ros2/workspace_tools.sh"
    fi

    if ! root="$(__rde_ros2_find_ws_root)"; then
        return 0
    fi

    RDE_WS_DETECTED=true
    RDE_WS_ROOT=$root
    RDE_WS_NAME=${root##*/}
    install="$root/install"

    if [[ -f "$install/setup.bash" ]]; then
        RDE_WS_BUILT=true
    fi
    if __rde_context_workspace_prefix_is_active "$install"; then
        RDE_WS_SOURCED=true
    fi
}
