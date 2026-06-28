#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT
passes=0 failures=0

pass() { printf 'ok - %s\n' "$1"; passes=$((passes + 1)); }
fail() { printf 'not ok - %s\n' "$1" >&2; failures=$((failures + 1)); }
assert() { local name=$1; shift; if "$@"; then pass "$name"; else fail "$name"; fi; }
count_marker() { [[ $(grep -Fc '# >>> RDE managed block >>>' "$HOME/.bashrc") -eq "$1" ]]; }

new_home() {
  export HOME="$TEST_ROOT/home-$RANDOM"
  export XDG_CONFIG_HOME="$HOME/config" XDG_STATE_HOME="$HOME/state" XDG_DATA_HOME="$HOME/data"
  export RDE_BIN_HOME="$HOME/bin" RDE_SKIP_PLATFORM_CHECK=true RDE_SKIP_WEZTERM_REPO=true
  mkdir -p "$HOME" "$HOME/fakes"
  PATH="$HOME/fakes:/usr/bin:/bin"
}

new_home
printf 'export USER_SETTING=1\n' > "$HOME/.bashrc"
"$ROOT/rde" install --components bash --yes >/dev/null
assert "install adds one managed Bash block" count_marker 1
"$ROOT/rde" install --components bash --yes >/dev/null
assert "second install remains idempotent" count_marker 1
assert "user Bash content is preserved" grep -Fqx 'export USER_SETTING=1' "$HOME/.bashrc"
"$ROOT/rde" uninstall --components bash --yes >/dev/null
assert "uninstall removes only the managed Bash block" test "$(grep -Fc '# >>> RDE managed block >>>' "$HOME/.bashrc")" -eq 0
assert "uninstall preserves user Bash content" grep -Fqx 'export USER_SETTING=1' "$HOME/.bashrc"

new_home
if "$ROOT/rde" install --yes >/dev/null 2>&1; then fail "non-interactive install requires a selection"; else pass "non-interactive install requires a selection"; fi
if "$ROOT/rde" install --components unknown --yes >/dev/null 2>&1; then fail "unknown component is rejected"; else pass "unknown component is rejected"; fi
if "$ROOT/rde" try --terminal unknown >/dev/null 2>&1; then fail "unknown temporary terminal is rejected"; else pass "unknown temporary terminal is rejected"; fi

new_home
cat > "$HOME/fakes/dpkg-query" <<'EOF'
#!/usr/bin/env bash
printf 'install ok installed\n'
EOF
cat > "$HOME/fakes/wezterm" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$HOME/fakes/dpkg-query" "$HOME/fakes/wezterm"
mkdir -p "$XDG_CONFIG_HOME/wezterm"
printf 'return {}\n' > "$XDG_CONFIG_HOME/wezterm/wezterm.lua"
"$ROOT/rde" install --components wezterm --yes >/dev/null
assert "WezTerm configuration becomes a managed link" test -L "$XDG_CONFIG_HOME/wezterm"
"$ROOT/rde" uninstall --components wezterm --restore --yes >/dev/null
assert "WezTerm backup can be restored" test -f "$XDG_CONFIG_HOME/wezterm/wezterm.lua"

new_home
cat > "$HOME/fakes/dpkg-query" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
cat > "$HOME/fakes/sudo" <<'EOF'
#!/usr/bin/env bash
"$@"
EOF
cat > "$HOME/fakes/apt-get" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$HOME/apt.log"
EOF
cat > "$HOME/fakes/fzf" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$HOME/fakes/"*
RDE_SUDO=sudo RDE_APT_GET=apt-get "$ROOT/rde" install --components fzf --yes >/dev/null
assert "newly installed packages are recorded" grep -Fq $'packages\tfzf' "$XDG_STATE_HOME/rde/state"
RDE_SUDO=sudo RDE_APT_GET=apt-get "$ROOT/rde" uninstall --components fzf --purge-packages --yes >/dev/null
assert "explicit purge invokes package removal" grep -Fq 'remove -y fzf' "$HOME/apt.log"

new_home
cat > "$HOME/fakes/dpkg-query" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
cat > "$HOME/fakes/sudo" <<'EOF'
#!/usr/bin/env bash
exit 42
EOF
chmod +x "$HOME/fakes/dpkg-query" "$HOME/fakes/sudo"
if RDE_SUDO=sudo "$ROOT/rde" install --components fzf --yes >/dev/null 2>&1; then fail "package failure stops installation"; else pass "package failure stops installation"; fi
assert "failed component is persisted for recovery" grep -Fq $'last_result\tfailed:fzf' "$XDG_STATE_HOME/rde/state"

new_home
remote="$HOME/remote.git" work="$HOME/release-work" managed="$HOME/data/rde"
git init --bare -q "$remote"
git init -q "$work"
git -C "$work" config user.email test@localhost
git -C "$work" config user.name 'RDE Test'
cat > "$work/rde" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$work/rde"
git -C "$work" add rde
git -C "$work" commit -qm v1
git -C "$work" tag v1.0.0
printf '# v2\n' >> "$work/rde"
git -C "$work" commit -qam v2
git -C "$work" tag v1.1.0
git -C "$work" remote add origin "$remote"
git -C "$work" push -q origin HEAD --tags
git clone -q "$remote" "$managed"
mkdir -p "$XDG_STATE_HOME/rde"
printf 'root\t%s\nversion\tv1.0.0\ncomponents\t\n' "$managed" > "$XDG_STATE_HOME/rde/state"
"$ROOT/rde" update --version v1.1.0 --yes >/dev/null
assert "update checks out the requested stable release" test "$(git -C "$managed" describe --tags --exact-match)" = v1.1.0
printf 'dirty\n' >> "$managed/rde"
if "$ROOT/rde" update --version v1.0.0 --yes >/dev/null 2>&1; then fail "update refuses a dirty checkout"; else pass "update refuses a dirty checkout"; fi

printf '\n%d passed, %d failed\n' "$passes" "$failures"
[[ $failures -eq 0 ]]
