#!/usr/bin/env bash
# Read-only ROS 2 environment detection.
# Detector result variables are consumed by context/rde-context.
# shellcheck disable=SC2034

__rde_context_detect_ros2() {
    RDE_ROS_CONFIGURED_DISTRO="${RDE_ROS_DISTRO:-jazzy}"
    RDE_ROS_ACTIVE_DISTRO="${ROS_DISTRO:-}"
    RDE_ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-}"
    RDE_ROS_INSTALL_PATH=''

    if command -v ros2 >/dev/null 2>&1; then
        RDE_ROS_COMMAND_AVAILABLE=true
    else
        RDE_ROS_COMMAND_AVAILABLE=false
    fi

    if [[ -n "${ROS_DISTRO:-}" ]]; then
        RDE_ROS_SOURCED=true
    else
        RDE_ROS_SOURCED=false
    fi

    if [[ -f "/opt/ros/$RDE_ROS_CONFIGURED_DISTRO/setup.bash" ]]; then
        RDE_ROS_INSTALL_PATH="/opt/ros/$RDE_ROS_CONFIGURED_DISTRO/setup.bash"
    fi
}
