# Bash

The Bash configuration is split into focused files under `bash/modules/`.
`bash/bashrc` finds its own directory and sources every readable `.sh` module
in numeric filename order, so the repository can live anywhere.

To test it safely from the repository root without changing `~/.bashrc`, run:

```bash
source bash/bashrc
```

For a completely isolated test, start `bash --noprofile --norc` first and then
run the same `source` command. ROS 2 remains optional: `srcros`, `srcws`, and
`cb` report a useful error when their required setup or command is unavailable.

## Customization

The final module loads `~/.rde.local` when it exists. Because it is loaded last,
it can override the defaults below as well as define aliases and functions:

| Variable | Default | Purpose |
| --- | --- | --- |
| `RDE_PROMPT_USER` | current user | Label shown in the prompt |
| `RDE_PROMPT_SHOW_HOST` | `false` | Show the current hostname |
| `RDE_PROMPT_SHOW_GIT` | `true` | Show a branch inside Git repositories |
| `RDE_ROS_DISTRO` | `jazzy` | Distribution sourced by `srcros` |

Copy the sanitized example only when you want to customize the environment:

```bash
cp examples/rde.local.example ~/.rde.local
```

The repository does not create or modify `~/.rde.local`. Keep personal paths,
hosts, workspace names, and aliases there and never commit the resulting file.
