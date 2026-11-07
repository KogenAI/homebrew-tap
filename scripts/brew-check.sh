# Runs the real Homebrew on Formula/kogen.rb of the working tree: style, audit, install and test
# from a committed temporary copy tapped as kogenai/tap, then removes everything the run added.
# Usage (repository root as current directory): sh scripts/brew-check.sh
HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_AUTO_UPDATE

# A non-interactive shell may not have Homebrew on PATH: look in the default prefixes after PATH.
if ! command -v brew >/dev/null 2>&1; then
  PATH="$PATH:/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.linuxbrew/bin"
  export PATH
fi

tap=kogenai/tap
formula=kogenai/tap/kogen
failed=0
list_ok=0
trust_ran=0
tap_ran=0

tmp=$(mktemp -d) || exit 1
mkdir "$tmp/out" "$tmp/repo" || { rm -rf "$tmp"; exit 1; }
out="$tmp/out/step"

# step <name> <command...>: capture the output; print it after the failure line on failure.
step() {
  name=$1
  shift
  if "$@" >"$out" 2>&1; then
    return 0
  fi
  echo "brew-check: failed at $name"
  cat "$out"
  failed=1
  return 1
}

copy_tree() {
  git ls-files --cached --others --exclude-standard | while IFS= read -r f; do
    [ -e "$f" ] || continue
    mkdir -p "$tmp/repo/$(dirname "$f")" && cp -p "$f" "$tmp/repo/$f" || exit 1
  done || return 1
  (
    cd "$tmp/repo" &&
      git init -q &&
      git add -A &&
      git -c user.name=brew-check -c user.email=brew-check@localhost -c commit.gpgsign=false \
        -c core.hooksPath=/dev/null commit -q --no-verify --allow-empty -m "brew-check"
  )
}

snapshot() { brew list --formula >"$tmp/before"; }

run_steps() {
  step copy copy_tree || return 1
  step list snapshot || return 1
  list_ok=1
  # Only a tap this run created is untapped: a failed tap (for example an existing kogenai/tap) stays.
  step tap brew tap "$tap" "$tmp/repo" || return 1
  tap_ran=1
  # A Homebrew without a trust subcommand has no untrusted taps: skip trust and untrust there.
  if brew trust --help >/dev/null 2>&1; then
    trust_ran=1
    step trust brew trust "$tap" || return 1
  fi
  step style brew style "$formula" || return 1
  step audit brew audit --strict "$formula" || return 1
  step install brew install "$formula" || return 1
  step test brew test "$formula" || return 1
}

uninstall_new() {
  brew list --formula >"$tmp/after" || return 1
  new=$(grep -vxFf "$tmp/before" "$tmp/after")
  [ -z "$new" ] && return 0
  # shellcheck disable=SC2086
  brew uninstall $new
}

run_cleanup() {
  status=0
  if [ "$list_ok" = 1 ]; then
    step_cleanup uninstall_new || status=1
  fi
  if [ "$trust_ran" = 1 ]; then
    step_cleanup brew untrust "$tap" || status=1
  fi
  if [ "$tap_ran" = 1 ]; then
    step_cleanup brew untap "$tap" || status=1
  fi
  return $status
}

# step_cleanup <command...>: collect the output of failing cleanup commands.
step_cleanup() {
  "$@" >"$out" 2>&1 && return 0
  cat "$out" >>"$tmp/cleanup-output"
  return 1
}

run_steps
cleanup_ok=0
run_cleanup && cleanup_ok=1
if [ "$cleanup_ok" = 0 ]; then
  echo "brew-check: failed at cleanup"
  cat "$tmp/cleanup-output"
fi
rm -rf "$tmp"

if [ "$failed" = 1 ] || [ "$cleanup_ok" = 0 ]; then
  exit 1
fi
echo "brew-check: passed"
