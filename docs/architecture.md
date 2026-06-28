# Architecture

WezTerm is the visual layer: windows, tabs, appearance, and key bindings. Bash is the operational layer: commands, prompt, and utilities. ROS 2, Git, Docker, and SSH are independent integrations built on top of those layers.

The future *context engine* will detect the active workspace, robot, and tools and act as the environment's single source of truth. Other layers will consume that context instead of detecting it independently. This avoids duplicated responsibilities and keeps components small and replaceable.
