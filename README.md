# Robotics Engineer Environment

Modular, version-controlled terminal environment for robotics development with WezTerm, Bash, and ROS 2.

Repository: <https://github.com/jlgalavi/Robotics-Engineer-Environment>

## Purpose

Bring the visual layer, shell tools, and future robotics integrations together in a maintainable project without aggressive automation or duplicated responsibilities.

## Current status

The modular Bash environment, private customization mechanism, and RDE v1
component manager are ready for testing on Ubuntu 24.04. The context engine,
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

## Development checkout (current method)

```bash
git clone https://github.com/jlgalavi/Robotics-Engineer-Environment.git
cd Robotics-Engineer-Environment
./rde try                              # temporary, changes nothing
./rde install --components bash,wezterm,fonts
./rde doctor
```

> **Release status:** the first stable release has not been published yet.
> Until a `vMAJOR.MINOR.PATCH` tag exists, `./install.sh` will stop with an
> explanatory error. Contributors and testers should use `./rde` directly.

RDE backs up existing configuration before adding its managed Bash block or
linking WezTerm. ROS 2 itself is never installed or sourced automatically.

Useful development commands:

```bash
./rde try
./rde install --profile default
./rde status
./rde uninstall --components fzf
```

## Stable installation (after the first release)

Once a stable tag has been published, the supported end-user entrypoint will
be:

```bash
./install.sh
```

The bootstrap will install its minimum dependencies, download the latest
stable release into `~/.local/share/rde`, and start the component selector. It
deliberately refuses to install an untagged `main` branch.

The Bash layer can still be tested safely with `source bash/bashrc`.

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

Please review [SECURITY.md](SECURITY.md) before sharing logs, screenshots, or
environment details.

> **Warning:** This project is experimental. Review scripts and backups before using it on a production machine.
