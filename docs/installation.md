# Installation

Run `./install.sh` from the repository root. The process first saves WezTerm and `.bashrc` under `~/.config/robotics-dev-environment/backups/<timestamp>`, preserves the previous configuration, and creates the WezTerm link. Bash remains a manual opt-in.

You do not need to install anything to test Bash. From the repository root:

```bash
bash --noprofile --norc
source bash/bashrc
```

This does not modify `~/.bashrc`. To customize the environment, copy
`examples/rde.local.example` to `~/.rde.local`. That file is loaded last,
stays outside the repository, and can override the defaults.
