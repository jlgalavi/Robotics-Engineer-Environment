# Installation and lifecycle

## Current development phase

RDE does not have its first stable release yet. Consequently, `install.sh`
cannot currently complete: it only accepts published tags matching
`vMAJOR.MINOR.PATCH` and never installs directly from `main`.

Use the repository command while developing or evaluating the project:

```bash
./rde try                                  # temporary environment
./rde install                              # interactive persistent install
./rde install --components bash,wezterm    # explicit persistent install
```

## Stable bootstrap

RDE v1 supports Ubuntu 24.04. `install.sh` discovers the newest stable
`vMAJOR.MINOR.PATCH` tag, creates a detached managed checkout under
`~/.local/share/rde`, and starts the component installer.
On a clean system it first installs the bootstrap requirements
`ca-certificates`, `curl`, `gnupg`, and `git` through APT. Further packages are
installed only for the components selected by the user.

```bash
./install.sh                 # available after the first stable release
./install.sh --profile full --yes
```

The available presets are `minimal` (Bash and Git), `default` (plus fzf), and
`full` (plus WezTerm and fonts). A profile is only a starting selection in the
interactive UI. ROS 2 installation is intentionally outside RDE.

## Commands

```bash
rde try                         # choose a temporary Bash or WezTerm session
rde try --terminal bash         # clean shell; exit returns to the normal shell
rde try --terminal wezterm      # new window using the repository configuration
rde install --components bash,git
rde update
rde status
rde doctor
rde uninstall --components wezterm --restore
rde uninstall --all
```

`rde try` never writes state, edits `.bashrc`, creates configuration links, or
installs packages. `rde install` is the persistent path and always shows its
plan before changing the user environment.

System packages require `sudo`. RDE records packages that were absent before
installation but preserves them during normal uninstall. Add
`--purge-packages` to explicitly offer their removal.

Configuration backups live under
`~/.config/robotics-dev-environment/backups`. Private overrides in
`~/.rde.local` are never created, changed, or removed by the manager.

## Local validation

Run the same checks used by CI from the repository root:

```bash
bash -n rde install.sh uninstall.sh lib/rde/*.sh scripts/*.sh tests/*.sh
shellcheck -x rde install.sh uninstall.sh tests/*.sh
bash tests/test-rde.sh
bash scripts/check-public-safety.sh
git diff --check
```

The `-x` option is required because `rde` sources its component libraries at
runtime; it lets ShellCheck follow the annotated source paths.
