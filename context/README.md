# Context Engine

The context engine is a read-only view of the current development environment.
In this phase it detects ROS 2, the current ROS 2 workspace, and Git state.

It does not source ROS 2, change directory, build a workspace, or perform any
remote Git operation. It is not connected to Bash startup, the prompt, WezTerm,
the status bar, Docker, or SSH.

## Usage

Run it from any directory:

```bash
./context/rde-context
./context/rde-context --format human
./context/rde-context --format shell
```

The default human format is intended for inspection. The shell format emits
only safely quoted assignments and can be evaluated by a caller if desired:

```bash
eval "$(./context/rde-context --format shell)"
```

ROS domain ID is left empty when `ROS_DOMAIN_ID` is unset, reflecting the
actual environment rather than substituting ROS 2's effective default.
