# Robotics Development Environment

Modular, version-controlled terminal environment for robotics development with WezTerm, Bash, and ROS 2.

## Purpose

Bring the visual layer, shell tools, and future robotics integrations together in a maintainable project without aggressive automation or duplicated responsibilities.

## Current status

The modular Bash environment and private customization mechanism are ready for
testing. WezTerm and installation support are in progress. The context engine,
standalone Docker and SSH integrations, profiles, status bar, and automatic
layouts are still planned or placeholder-only.

See [Project Status and Roadmap](ROADMAP.md) for the detailed implementation
matrix, current limitations, and upcoming milestones.

## Structure

- `wezterm/`: visual terminal configuration.
- `bash/`: Bash entrypoint and numbered modules for the prompt, Git, and ROS 2.
- `scripts/`: backup, linking, diagnostics, and public-safety checks.
- `docs/`: architecture and usage guides.
- `context/`, `ros2/`, `git/`, `docker/`, `ssh/`, `profiles/`: foundations for future integrations.

## Provisional installation

```bash
cd ~/dev/robotics-dev-environment
./install.sh
./scripts/healthcheck.sh
```

The installer creates a timestamped backup before linking WezTerm. It does not modify `~/.bashrc`.

The Bash layer can be tested safely from the repository root with
`source bash/bashrc`.

Private customization belongs in `~/.rde.local`, which is loaded last and
ignored by Git. The repository never creates this file automatically:

```bash
cp examples/rde.local.example ~/.rde.local
```

Before publishing changes, `./scripts/check-public-safety.sh` searches for
personal paths, email addresses, and credential patterns that require review.

## Contributing

Contributions are welcome, particularly portability fixes, documentation,
tests, and small implementations from the roadmap. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. It explains
the fork-based contribution workflow, project scope, safety rules, validation
steps, and how contributors are recognized.

> **Warning:** This project is experimental. Review scripts and backups before using it on a production machine.
