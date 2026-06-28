# Contributing

Contributions are welcome. This project is still experimental, so small,
focused improvements with clear behavior are especially valuable.

## Before starting

Read the [project status and roadmap](ROADMAP.md) to distinguish implemented
features from placeholders. For larger changes, open a discussion or issue
first so the intended behavior and scope can be agreed before implementation.

Good contribution areas include:

- portability fixes for Bash and WezTerm;
- documentation and generic customization examples;
- tests for existing behavior;
- context-engine design and detectors;
- conservative ROS 2, Git, Docker, and SSH helpers;
- accessibility and usability improvements.

## Development guidelines

- Keep all repository content in English.
- Keep changes focused and avoid external dependencies unless clearly justified.
- Never commit personal usernames, emails, hosts, IP addresses, workspace paths,
  credentials, keys, tokens, or private configuration.
- Put machine-specific settings in `~/.rde.local`, not in repository modules.
- Do not automatically modify user dotfiles or source ROS 2 environments.
- Make optional integrations behave safely when their tools are not installed.
- Add comments where behavior or safety constraints are not obvious.

## Testing changes

Run the relevant checks from the repository root:

```bash
bash -n bash/bashrc bash/modules/*.sh scripts/*.sh
./scripts/check-public-safety.sh
bash --noprofile --norc
source bash/bashrc
```

Run ShellCheck on changed shell files when it is available. For WezTerm
changes, start WezTerm with the repository configuration and verify that
optional fonts, images, and tools are handled gracefully.

The public-safety script is heuristic. Review the full diff manually before
submitting a change, including hidden files and image metadata where relevant.

## Submitting a contribution

Public contributors should work from a fork. Branches in the main repository
are created only by maintainers and collaborators with the appropriate access.

1. Fork the repository to your own GitHub account.
2. Create a focused branch in your fork.
3. Make the smallest complete change that solves the problem.
4. Update documentation and the roadmap status when behavior changes.
5. Run the syntax, safety, and relevant manual checks.
6. Open a pull request from your fork explaining the motivation, behavior,
   validation, and any known limitations.

Avoid mixing unrelated formatting or cleanup with functional changes. This
keeps reviews useful and makes regressions easier to identify.

## Reporting sensitive data

Do not include credentials or private infrastructure details in issues, pull
requests, screenshots, or logs. If sensitive data is discovered, remove it
from the proposed change and rotate any exposed credential before continuing.

## Recognition

Contributors are recognized through the repository history and release notes.
Substantial contributions may also be highlighted in project documentation.
