# ROS 2

These Bash helpers provide explicit ROS 2 environment activation, workspace
discovery, builds, and cleanup. ROS 2 is **not sourced automatically**.

## Commands

- `srcros` sources `/opt/ros/$RDE_ROS_DISTRO/setup.bash` (`jazzy` by default).
- `srcws` sources the detected workspace's `install/setup.bash`.
- `wsroot` prints the detected workspace root; `wscd` changes to it.
- `wsbuild [pkg <package>] [options...]` builds normally, optionally selecting
  one package.
- `wsbuild_symlink [pkg <package>] [options...]` does the same with
  `--symlink-install`.
- `wspkg <package> [options...]` remains available as a package-only,
  symlink-build compatibility function.
- `wsclean` confirms before removing the workspace's `build/`, `install/`, and
  `log/` directories.

The canonical commands above are functions. Convenience aliases are defined
only in `aliases.sh`: `ws` maps to `wscd`, `cb` to `wsbuild`, and `cbs` to
`wsbuild_symlink`. Therefore `cb` builds normally and `cbs` builds with
symlinks; both accept `pkg <package>` before any additional colcon options. The
`rn`, `rt`, `rs`, `rp`, `ra`, and `ri` aliases are ROS 2 command prefixes, so
additional subcommands and options can be appended.

Workspace-aware commands search upward from the current directory. This lets
`srcws`, `wsbuild`, and `wspkg` work from nested paths such as
`src/package/launch`.

`cb` and `cbs` autocomplete the `pkg` keyword and then the package name.
`wspkg` autocompletes its package directly. Package candidates come from the
currently sourced ROS 2 environment (`ros2 pkg list`), so source ROS 2 and,
when appropriate, the workspace before using completion.
