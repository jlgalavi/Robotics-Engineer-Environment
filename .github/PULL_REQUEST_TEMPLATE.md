## Summary

<!-- Briefly describe the change. -->

## Motivation

<!-- What problem does this solve, and why is the change needed? -->

## Type of change

- [ ] Documentation
- [ ] Bash environment
- [ ] WezTerm configuration
- [ ] ROS 2 helpers
- [ ] Context engine
- [ ] Scripts / tooling
- [ ] Public safety / cleanup
- [ ] Other

## Validation performed

- [ ] `bash -n bash/bashrc bash/modules/*.sh scripts/*.sh`
- [ ] `./scripts/check-public-safety.sh`
- [ ] Manually tested with `bash --noprofile --norc` and `source bash/bashrc`
- [ ] ShellCheck, if available
- [ ] Not applicable; explained below

<!-- Add relevant results or explain checks that do not apply. -->

## Public-safety checklist

- [ ] No personal usernames, emails, hosts, IP addresses, or private paths
- [ ] No credentials, tokens, SSH keys, or secrets
- [ ] No private company or infrastructure details
- [ ] Machine-specific settings belong in `~/.rde.local`

## Documentation updated

- [ ] Documentation was updated where required
- [ ] No documentation changes are required

## Known limitations

<!-- Describe limitations, follow-up work, or write "None". -->
