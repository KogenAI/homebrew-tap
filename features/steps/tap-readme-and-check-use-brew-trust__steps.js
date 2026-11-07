'use strict';
// Steps for the brew-trust Intent: README.md text checks and scripts/brew-check.sh run against a fake
// Homebrew on PATH. The fake and the sandbox repository are literals written by these steps; nothing here
// runs the real brew or reads a file the Build changes except the README under test and the script under test.
const { Given, When, Then, After } = require('@cucumber/cucumber');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const P = 'tap-readme-and-check-use-brew-trust: ';
const ROOT = process.cwd();
const CHECKED = new Set(['tap', 'trust', 'style', 'audit', 'install', 'test', 'untrust', 'untap']);

const FORMULA = 'class Kogen < Formula\n  url "https://example.invalid/kogen.tar.gz"\nend\n';

// State lives in $TRCB_STATE: calls (every invocation), taps, trusted, installed, ok (successful install/test),
// tap-dir, and no-trust (present: this Homebrew has no trust subcommand).
const FAKE_BREW = String.raw`#!/bin/sh
s="$TRCB_STATE"
echo "$*" >>"$s/calls"
sub=$1
[ $# -gt 0 ] && shift
has() { [ -f "$s/$1" ] && grep -qxF "$2" "$s/$1"; }
drop() { if [ -f "$s/$1" ]; then grep -vxF "$2" "$s/$1" >"$s/$1.new"; mv "$s/$1.new" "$s/$1"; fi; }
last() { l=; for a in "$@"; do l=$a; done; echo "$l"; }
has_trust() { [ ! -f "$s/no-trust" ]; }
formula() {
  if [ "$(last "$@")" != kogenai/tap/kogen ] || ! has taps kogenai/tap; then
    echo "Error: No available formula with the name \"$(last "$@")\"."
    exit 1
  fi
}
loadable() {
  if has_trust && ! has trusted kogenai/tap; then
    echo "Error: Refusing to load formula kogenai/tap/kogen from untrusted tap kogenai/tap."
    exit 1
  fi
}
case "$sub" in
tap)
  if [ $# -eq 0 ]; then [ -f "$s/taps" ] && cat "$s/taps"; exit 0; fi
  if [ "$1" != kogenai/tap ] || [ $# -ne 2 ]; then echo "fake brew: unexpected tap arguments: $*"; exit 1; fi
  if ! git -C "$2" show HEAD:Formula/kogen.rb >/dev/null 2>&1; then echo "Error: no committed Formula/kogen.rb in $2"; exit 1; fi
  echo "$2" >"$s/tap-dir"
  echo kogenai/tap >>"$s/taps" ;;
trust|untrust)
  if ! has_trust; then echo "Error: Unknown command: brew $sub"; exit 1; fi
  case "$1" in -h|--help) echo "Usage: brew $sub tap"; exit 0 ;; esac
  if [ "$sub" = trust ]; then
    if [ $# -ne 1 ] || [ "$1" != kogenai/tap ]; then echo "fake brew: brew trust takes the tap name: $*"; exit 1; fi
    has trusted kogenai/tap || echo kogenai/tap >>"$s/trusted"
  else
    [ "$1" = --tap ] && shift
    if [ $# -ne 1 ] || [ "$1" != kogenai/tap ]; then echo "fake brew: unexpected untrust arguments"; exit 1; fi
    drop trusted kogenai/tap
  fi ;;
untap)
  has taps kogenai/tap || { echo "Error: No available tap kogenai/tap."; exit 1; }
  drop taps kogenai/tap ;;
style) formula "$@" ;;
audit) formula "$@"; loadable ;;
install)
  formula "$@"; loadable
  has installed node || echo node >>"$s/installed"
  has installed kogen || echo kogen >>"$s/installed"
  echo install >>"$s/ok" ;;
test)
  formula "$@"; loadable
  has installed kogen || { echo "Error: kogenai/tap/kogen is not installed."; exit 1; }
  echo test >>"$s/ok" ;;
list) [ -f "$s/installed" ] && sort "$s/installed"; exit 0 ;;
uninstall)
  for a in "$@"; do
    case "$a" in -*) continue ;; esac
    has installed "$a" || { echo "Error: No such keg: $a"; exit 1; }
    drop installed "$a"
  done ;;
help) if [ "$1" = trust ] && ! has_trust; then exit 1; fi; exit 0 ;;
commands) echo tap; echo install; has_trust && echo trust; exit 0 ;;
*) exit 0 ;;
esac
exit 0
`;

function cleanEnv(extra) {
  const env = {};
  for (const [k, v] of Object.entries(process.env)) if (!k.startsWith('GIT_')) env[k] = v;
  return Object.assign(env, extra);
}

function run(cmd, args, opts) {
  const res = spawnSync(cmd, args, Object.assign({ encoding: 'utf8', env: cleanEnv({}) }, opts));
  return { status: res.status, out: `${res.stdout || ''}${res.stderr || ''}` };
}

function git(cwd, args) {
  const r = run('git', ['-c', 'user.name=acceptance', '-c', 'user.email=acceptance@localhost', '-c', 'commit.gpgsign=false', ...args], { cwd });
  if (r.status !== 0) throw new Error(`git ${args.join(' ')} failed in ${cwd} (status ${r.status}): ${r.out}`);
}

function base(world) {
  if (!world.trcb) world.trcb = { base: fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'trcb-'))) };
  return world.trcb;
}

After(function () {
  if (this.trcb) fs.rmSync(this.trcb.base, { recursive: true, force: true });
});

function lineList(text) {
  const lines = text.split('\n');
  if (lines[lines.length - 1] === '') lines.pop();
  return lines;
}

function repoText(rel) {
  const p = path.join(ROOT, rel);
  assert.ok(fs.existsSync(p), `${rel} does not exist in the repository`);
  return fs.readFileSync(p, 'utf8');
}

// README.md

Then(P + 'the file {string} has exactly one line containing {string}, and that line is exactly {string}', function (rel, needle, whole) {
  const hits = lineList(repoText(rel)).filter((l) => l.includes(needle));
  assert.equal(hits.length, 1, `${rel}: lines containing ${JSON.stringify(needle)}: ${JSON.stringify(hits)}`);
  assert.equal(hits[0].trim(), whole, `${rel}: the line containing ${JSON.stringify(needle)}`);
});

Then(P + 'the file {string} contains {string}', function (rel, text) {
  assert.ok(repoText(rel).includes(text), `${rel} does not contain ${JSON.stringify(text)}`);
});

Then(P + 'the file {string} does not contain {string}', function (rel, text) {
  assert.ok(!repoText(rel).includes(text), `${rel} contains ${JSON.stringify(text)}`);
});

Then(P + 'the file {string} names no release version', function (rel) {
  const m = repoText(rel).match(/v?\d+\.\d+\.\d+\S*/);
  assert.equal(m, null, `${rel} names a release version: ${m && m[0]}`);
});

Then(P + 'the file {string} has at most {int} lines', function (rel, max) {
  const n = lineList(repoText(rel)).length;
  assert.ok(n <= max, `${rel} has ${n} lines, more than ${max}`);
});

// brew-check.sh against a fake Homebrew

Given(P + 'a sandbox repository with a committed formula file', function () {
  const b = base(this);
  b.sandbox = path.join(b.base, 'sandbox');
  fs.mkdirSync(path.join(b.sandbox, 'Formula'), { recursive: true });
  fs.writeFileSync(path.join(b.sandbox, 'Formula', 'kogen.rb'), FORMULA);
  git(b.sandbox, ['init', '-q']);
  git(b.sandbox, ['add', '-A']);
  git(b.sandbox, ['commit', '-q', '--no-verify', '-m', 'sandbox']);
});

function fakeBrew(world, withTrust) {
  const b = base(world);
  b.fakebin = path.join(b.base, 'fakebin');
  b.state = path.join(b.base, 'state');
  b.tmp = path.join(b.base, 'tmp');
  for (const d of [b.fakebin, b.state, b.tmp]) fs.mkdirSync(d, { recursive: true });
  fs.writeFileSync(path.join(b.fakebin, 'brew'), FAKE_BREW, { mode: 0o755 });
  fs.writeFileSync(path.join(b.state, 'installed'), 'wget\n');
  if (!withTrust) fs.writeFileSync(path.join(b.state, 'no-trust'), '');
}

Given(P + 'a fake Homebrew on PATH that has the trust subcommand, refuses to audit, install or test a formula from an untrusted tap, and has wget installed', function () {
  fakeBrew(this, true);
});

Given(P + 'a fake Homebrew on PATH that has no trust subcommand and has wget installed', function () {
  fakeBrew(this, false);
});

When(P + 'I run brew-check.sh in the sandbox', function () {
  const b = this.trcb;
  const script = path.join(ROOT, 'scripts', 'brew-check.sh');
  const outFile = path.join(b.base, 'brew-check.out');
  const fd = fs.openSync(outFile, 'w');
  let res;
  try {
    res = spawnSync('sh', [script], {
      cwd: b.sandbox,
      stdio: ['ignore', fd, fd],
      timeout: 90000,
      env: cleanEnv({ PATH: `${b.fakebin}${path.delimiter}${process.env.PATH}`, TRCB_STATE: b.state, TMPDIR: b.tmp }),
    });
  } finally {
    fs.closeSync(fd);
  }
  const callsPath = path.join(b.state, 'calls');
  b.check = {
    status: res.status,
    error: res.error ? res.error.message : '',
    out: fs.readFileSync(outFile, 'utf8'),
    calls: fs.existsSync(callsPath) ? lineList(fs.readFileSync(callsPath, 'utf8')) : [],
  };
});

function report(b) {
  return `exit ${b.check.status}${b.check.error ? ` (${b.check.error})` : ''}; output:\n${b.check.out}\nbrew calls: ${JSON.stringify(b.check.calls)}`;
}

function stateLines(b, name) {
  const p = path.join(b.state, name);
  return fs.existsSync(p) ? lineList(fs.readFileSync(p, 'utf8')) : [];
}

Then(P + 'brew-check.sh exited with status 0', function () {
  assert.equal(this.trcb.check.status, 0, `sh scripts/brew-check.sh: ${report(this.trcb)}`);
});

Then(P + 'the last line of the brew-check output is {string}', function (want) {
  const lines = lineList(this.trcb.check.out);
  assert.equal(lines[lines.length - 1], want, `last output line; ${report(this.trcb)}`);
});

Then(P + 'the brew-check output does not contain {string}', function (text) {
  assert.ok(!this.trcb.check.out.includes(text), `output contains ${JSON.stringify(text)}; ${report(this.trcb)}`);
});

// The commands that matter: tap (with arguments), trust, style, audit, install, test, untrust, untap. Help
// probes (--help, -h), `brew tap` alone, list, uninstall and the like are not part of the sequence. An untrust
// call shows as `untrust kogenai/tap` with or without --tap.
Then(P + 'the fake Homebrew received exactly these commands, in order:', function (table) {
  const b = this.trcb;
  const main = b.check.calls.filter((c) => {
    const words = c.split(' ');
    if (!CHECKED.has(words[0])) return false;
    if (words[0] === 'tap' && words.length === 1) return false;
    return !words.includes('--help') && !words.includes('-h');
  });
  const sandbox = fs.realpathSync(b.sandbox);
  const shown = main.map((c) => {
    const tapped = c.match(/^tap kogenai\/tap (\/.+)$/);
    if (tapped) {
      const dir = fs.existsSync(tapped[1]) ? fs.realpathSync(tapped[1]) : tapped[1];
      return dir === sandbox ? 'tap kogenai/tap <the sandbox itself, not a temporary copy>' : 'tap kogenai/tap <temporary copy>';
    }
    return c === 'untrust --tap kogenai/tap' ? 'untrust kogenai/tap' : c;
  });
  assert.deepEqual(shown, table.raw().map((r) => r[0]), `main brew commands in order; ${report(b)}`);
});

Then(P + 'the fake Homebrew completed the install and the test of the formula', function () {
  const b = this.trcb;
  assert.deepEqual(stateLines(b, 'ok'), ['install', 'test'], `successful install and test; ${report(b)}`);
});

Then(P + 'the fake Homebrew has no tap and no trusted tap and only wget installed', function () {
  const b = this.trcb;
  assert.deepEqual(stateLines(b, 'taps'), [], `fake Homebrew taps after brew-check.sh; ${report(b)}`);
  assert.deepEqual(stateLines(b, 'trusted'), [], `fake Homebrew trusted taps after brew-check.sh; ${report(b)}`);
  assert.deepEqual(stateLines(b, 'installed'), ['wget'], `fake Homebrew installed formulae after brew-check.sh; ${report(b)}`);
});
