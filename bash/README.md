# Bash

`bash/bashrc` is the modular entrypoint. It loads every readable `.sh` file in
`bash/modules/` in filename order. The numeric prefixes make that order clear.

From the repository root, test the configuration safely in the current shell:

```bash
source bash/bashrc
```

This does not copy, replace, or edit `~/.bashrc`. Start a temporary clean shell
first if you want an isolated test:

```bash
bash --noprofile --norc
source bash/bashrc
```

ROS 2 is optional and is not sourced automatically. Use `srcros` for ROS 2
Jazzy, `srcws` from a built workspace root, and `cb` to run a symlink build.

## Local customization

`bash/modules/90-local.sh` loads `~/.rde.local` last, if the file exists. This
allows personal settings to override repository defaults without putting names,
paths, hosts, or aliases in Git. The repository never creates this file.

Create it explicitly from the public-safe example:

```bash
cp examples/rde.local.example ~/.rde.local
```

Supported variables are:

- `RDE_PROMPT_USER`: prompt label; defaults to the current account name.
- `RDE_PROMPT_SHOW_HOST`: `true` shows the current hostname; default `false`.
- `RDE_PROMPT_SHOW_GIT`: `true` shows Git branches; default `true`.
- `RDE_ROS_DISTRO`: distribution used by `srcros`; default `jazzy`.

Keep `~/.rde.local` private. It is intended for machine-specific aliases,
workspace paths, and other values that should not be committed.
