# Project Status and Roadmap

This document describes what is usable today and what remains planned. A
directory existing in the repository does not necessarily mean that its
integration is implemented.

Status labels:

- **Ready:** implemented and suitable for normal testing.
- **In progress:** usable foundations exist, but the feature is incomplete.
- **Planned:** structure or placeholders exist; no supported workflow yet.

## Current status

| Area | Status | What works today | Remaining work |
| --- | --- | --- | --- |
| Bash modules | **Ready** | Ordered module loading, history, aliases, utilities, paths, Git-aware prompt, ROS 2 helpers, and private local overrides | Broader platform testing and additional tests |
| Local customization | **Ready** | `~/.rde.local` loads last; a sanitized example is provided | Document more optional recipes as real use cases emerge |
| Public-safety checks | **Ready** | Heuristic scan for personal paths, emails, credentials, SSH hosts, and IP addresses | Add automated CI execution |
| WezTerm | **In progress** | Modular appearance, themes, font selection, panes, tabs, and key bindings | Portability testing, optional backgrounds, and documented customization |
| Installation | **Ready** | Interactive and scriptable component manager, stable-release updates, state, backups, diagnostics, and conservative uninstall on Ubuntu 24.04 | Publish the first stable tag, then broaden platform testing and release automation |
| ROS 2 Bash support | **In progress** | Configurable Jazzy sourcing, workspace sourcing, colcon build helpers, and inspection aliases | Implement the standalone files under `ros2/` and add workspace/launch/topic workflows |
| Git integration | **In progress** | Bash aliases and prompt branch detection | Define the standalone `git/` integration without identity or credential settings |
| Context engine | **Planned** | Directory structure and detector entrypoints only | Implement detection, a stable output contract, and tests |
| Docker integration | **Planned** | Directory structure only | Define safe aliases and container workflows |
| SSH integration | **Planned** | Sanitized empty profile example only | Define profile schema and helpers without storing hosts or credentials |
| Profiles | **Ready** | Validated minimal YAML presets for minimal, default, and full installations | Add profiles only as supported components expand |
| Smart status bar | **Planned** | No implementation | Consume context-engine output without duplicating detection |
| Automatic layouts | **Planned** | No implementation | Design optional layouts for builds, launches, topics, and logs |
| Automated tests and CI | **Ready** | Isolated installer lifecycle tests, Bash syntax, ShellCheck, and public-safety checks run in CI | Expand fixtures as components and supported platforms grow |

## Milestones

### 1. Stabilize the foundation

- Document supported Linux distributions and required tools.
- Add automated checks for Bash syntax, clean-shell loading, and module order.
- Test backup, linking, and uninstall behavior in temporary home directories.
- Improve WezTerm portability when optional fonts or backgrounds are missing.

### 2. Define the context engine

- Specify a small, stable context format.
- Detect Git, ROS 2, workspace, Python, Docker, and SSH state independently.
- Keep detection read-only and fast.
- Add tests for environments where tools are absent.

### 3. Expand robotics workflows

- Add reviewed ROS 2 workspace, build, launch, and topic helpers.
- Make every distribution and workspace path configurable.
- Add optional Docker and remote-robot workflows without embedding private data.

### 4. Integrate the terminal experience

- Feed context into the WezTerm status bar.
- Add optional, explicit workspace layouts.
- Keep Bash and WezTerm useful when advanced integrations are disabled.

## Project principles

- No automatic modification of `~/.bashrc`.
- No credentials, identities, private hosts, or personal paths in the repository.
- No required prompt framework or shell replacement.
- Optional tools must fail gracefully when unavailable.
- Features should remain small, transparent, and independently testable.

See [CONTRIBUTING.md](CONTRIBUTING.md) for ways to help move planned areas
forward.
