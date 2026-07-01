#!/usr/bin/env bash
# Load the ROS 2 helpers. ROS itself is never sourced automatically.

RDE_ROS_DISTRO="${RDE_ROS_DISTRO:-jazzy}"

_rde_ros2_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"

for _rde_ros2_module in \
    workspace_tools.sh \
    environment.sh \
    colcon_tools.sh \
    aliases.sh; do
    if [[ -r "${_rde_ros2_root}/ros2/${_rde_ros2_module}" ]]; then
        # shellcheck disable=SC1090
        source "${_rde_ros2_root}/ros2/${_rde_ros2_module}"
    fi
done

unset _rde_ros2_module _rde_ros2_root
