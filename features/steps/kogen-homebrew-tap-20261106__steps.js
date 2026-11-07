'use strict';
// Steps for the Homebrew tap Intent: file contents, update-formula.sh on a temporary copy and
// brew-check.sh against a fake Homebrew on PATH. Nothing here runs the real brew or downloads a release.
const { Given, When, Then, After } = require('@cucumber/cucumber');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const P = 'kogen-homebrew-tap-20261106: ';
const ROOT = process.cwd();
const MAIN_COMMANDS = new Set(['tap', 'trust', 'style', 'audit', 'install', 'test', 'untrust', 'untap']);

const FAKE_BREW = `#!/bin/sh
# Fake Homebrew for the kogen-homebrew-tap-20261106 acceptance: state lives in $KGHT_FAKE_BREW_STATE.
s="$KGHT_FAKE_BREW_STATE"
printf '%s\\n' "$*" >>"$s/calls"
sub=\${1:-}
[ $# -gt 0 ] && shift
has() { [ -f "$s/$1" ] && grep -qxF "$2" "$s/$1"; }
drop() { if [ -f "$s/$1" ]; then grep -vxF "$2" "$s/$1" >"$s/$1.new"; mv "$s/$1.new" "$s/$1"; fi; }
injected() { if [ -f "$s/fail-$sub" ]; then cat "$s/fail-$sub"; exit 1; fi; }
last() { l=""; for a in "$@"; do l=$a; done; printf '%s' "$l"; }
formula() {
  f=$(last "$@")
  if [ "$f" != kogenai/tap/kogen ] || ! has taps kogenai/tap; then echo "Error: No available formula with the name \\"$f\\"."; exit 1; fi
}
trusted() { has trusted kogenai/tap || { echo "Error: Refusing to load formula kogenai/tap/kogen from untrusted tap kogenai/tap."; exit 1; }; }
case "$sub" in
tap)
  if [ $# -eq 0 ]; then [ -f "$s/taps" ] && cat "$s/taps"; exit 0; fi
  if [ "$1" != kogenai/tap ] || [ $# -ne 2 ]; then echo "fake brew: unexpected tap arguments: $*"; exit 1; fi
  if has taps kogenai/tap; then echo "Error: Tap kogenai/tap already tapped."; exit 1; fi
  if ! git -C "$2" show HEAD:Formula/kogen.rb >"$s/tapped-formula.rb" 2>/dev/null; then echo "Error: cannot clone $2: no committed Formula/kogen.rb"; exit 1; fi
  injected
  printf '%s\\n' "$2" >"$s/tap-dir"
  echo kogenai/tap >>"$s/taps" ;;
trust)
  [ "$(last "$@")" = kogenai/tap ] || { echo "fake brew: unexpected trust arguments: $*"; exit 1; }
  injected
  has trusted kogenai/tap || echo kogenai/tap >>"$s/trusted" ;;
untrust)
  [ "$(last "$@")" = kogenai/tap ] || { echo "fake brew: unexpected untrust arguments: $*"; exit 1; }
  drop trusted kogenai/tap ;;
untap)
  has taps kogenai/tap || { echo "Error: No available tap kogenai/tap."; exit 1; }
  drop taps kogenai/tap ;;
style) formula "$@"; injected ;;
audit) formula "$@"; trusted; injected ;;
install)
  formula "$@"; trusted; injected
  has installed node || echo node >>"$s/installed"
  has installed kogen || echo kogen >>"$s/installed" ;;
test)
  formula "$@"; trusted
  has installed kogen || { echo "Error: kogenai/tap/kogen is not installed."; exit 1; }
  injected ;;
list) [ -f "$s/installed" ] && sort "$s/installed"; exit 0 ;;
uninstall)
  names=""
  for a in "$@"; do
    case "$a" in -*) continue ;; esac
    n=\${a##*/}
    has installed "$n" || { echo "Error: No such keg: $n"; exit 1; }
    names="$names $n"
  done
  case " $names " in
  *" node "*) case " $names " in *" kogen "*) ;; *) if has installed kogen; then echo "Error: Refusing to uninstall node because it is required by kogen."; exit 1; fi ;; esac ;;
  esac
  for n in $names; do drop installed "$n"; done ;;
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
  return { status: res.status, out: `${res.stdout || ''}${res.stderr || ''}`, error: res.error };
}

function git(cwd, args) {
  const r = run('git', ['-c', 'user.name=acceptance', '-c', 'user.email=acceptance@localhost', '-c', 'commit.gpgsign=false', ...args], { cwd });
  if (r.status !== 0) throw new Error(`git ${args.join(' ')} failed in ${cwd} (status ${r.status}): ${r.out}`);
}

function base(world) {
  if (!world.kght) world.kght = { base: fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'kght-'))) };
  return world.kght;
}

After(function () {
  if (this.kght) fs.rmSync(this.kght.base, { recursive: true, force: true });
});

function repoText(rel) {
  const p = path.join(ROOT, rel);
  return fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : null;
}

function requireRepoText(rel) {
  const text = repoText(rel);
  assert.ok(text !== null, `${rel} does not exist in the repository`);
  return text;
}

function lineList(text) {
  const lines = text.split('\n');
  if (lines[lines.length - 1] === '') lines.pop();
  return lines;
}

function listFiles(dir, rel, skip, out) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const r = rel ? `${rel}/${entry.name}` : entry.name;
    if (skip.has(r)) continue;
    if (entry.isDirectory()) listFiles(path.join(dir, entry.name), r, skip, out);
    else out.push(r);
  }
  return out;
}

// Formula and documentation

Then(P + 'the file {string} has exactly these url lines, each followed by its sha256 line:', function (rel, table) {
  const lines = lineList(requireRepoText(rel));
  const urlRe = /^\s*url "([^"]*)"/;
  const shaRe = /^\s*sha256 "([^"]*)"/;
  const found = [];
  lines.forEach((line, i) => {
    const m = line.match(urlRe);
    if (!m) return;
    let sha = null;
    for (let j = i + 1; j < lines.length && !urlRe.test(lines[j]); j++) {
      const s = lines[j].match(shaRe);
      if (s) { sha = s[1]; break; }
    }
    found.push({ url: m[1], sha256: sha });
  });
  const want = table.hashes().map((r) => ({ url: r.url, sha256: r.sha256 }));
  const key = (e) => `${e.url} ${e.sha256}`;
  assert.deepEqual(found.map(key).sort(), want.map(key).sort(), `${rel}: url lines with the sha256 line that follows each`);
});

Then(P + 'the file {string} has these lines:', function (rel, table) {
  const lines = lineList(requireRepoText(rel)).map((l) => l.trim());
  for (const [want] of table.raw()) assert.ok(lines.includes(want), `${rel} has no line ${JSON.stringify(want)}`);
});

Then(P + 'the file {string} contains {string}', function (rel, text) {
  assert.ok(requireRepoText(rel).includes(text), `${rel} does not contain ${JSON.stringify(text)}`);
});

Then(P + 'the file {string} is exactly:', function (rel, doc) {
  assert.equal(requireRepoText(rel), `${doc}\n`, `${rel} content`);
});

Then(P + 'the file {string} has exactly one line containing {string}, and that line contains {string}', function (rel, needle, whole) {
  const hits = lineList(requireRepoText(rel)).filter((l) => l.includes(needle));
  assert.equal(hits.length, 1, `${rel}: lines containing ${JSON.stringify(needle)}: ${JSON.stringify(hits)}`);
  assert.ok(hits[0].includes(whole), `${rel}: ${JSON.stringify(hits[0])} does not contain ${JSON.stringify(whole)}`);
});

Then(P + 'the first line of {string} starts with {string} and contains:', function (rel, start, table) {
  const first = lineList(requireRepoText(rel))[0] || '';
  assert.ok(first.startsWith(start), `${rel} line 1 ${JSON.stringify(first)} does not start with ${JSON.stringify(start)}`);
  for (const [want] of table.raw()) assert.ok(first.includes(want), `${rel} line 1 ${JSON.stringify(first)} does not contain ${JSON.stringify(want)}`);
});

Then(P + 'the repository files outside .git, .kogen and features are exactly:', function (table) {
  const files = listFiles(ROOT, '', new Set(['.git', '.kogen', 'features', 'node_modules']), []).sort();
  assert.deepEqual(files, table.raw().map((r) => r[0]).sort(), 'repository files outside .git, .kogen and features');
});

// update-formula.sh on a temporary copy

Given(P + 'a temporary copy of {string} and {string}', function (formula, script) {
  const b = base(this);
  b.update = path.join(b.base, 'update');
  for (const rel of [formula, script]) {
    const text = repoText(rel);
    if (text === null) continue;
    fs.mkdirSync(path.dirname(path.join(b.update, rel)), { recursive: true });
    fs.writeFileSync(path.join(b.update, rel), text);
  }
  b.formulaRel = formula;
  b.scriptRel = script;
});

When(P + 'I run update-formula.sh in the copy with {string} {string} {string}', function (version, arm64, linux) {
  const b = this.kght;
  const formulaPath = path.join(b.update, b.formulaRel);
  b.before = fs.existsSync(formulaPath) ? fs.readFileSync(formulaPath, 'utf8') : null;
  b.updateRun = run('sh', [b.scriptRel, version, arm64, linux], { cwd: b.update, timeout: 60000 });
});

Then(P + 'update-formula.sh exited with status 0', function () {
  const r = this.kght.updateRun;
  assert.equal(r.status, 0, `sh ${this.kght.scriptRel} exited with ${r.status}${r.error ? ` (${r.error.message})` : ''}: ${r.out}`);
});

Then(P + 'the copied formula equals the formula before that run with these replacements:', function (table) {
  const b = this.kght;
  assert.ok(b.before !== null, `${b.formulaRel} does not exist in the repository`);
  const after = fs.readFileSync(path.join(b.update, b.formulaRel), 'utf8');
  const edits = table.hashes().map((r) => {
    const first = b.before.indexOf(r.from);
    assert.ok(first >= 0, `${b.formulaRel} before the run has no ${JSON.stringify(r.from)}`);
    assert.equal(b.before.indexOf(r.from, first + 1), -1, `${b.formulaRel} before the run has ${JSON.stringify(r.from)} more than once`);
    return { at: first, from: r.from, to: r.to };
  }).sort((x, y) => x.at - y.at);
  let expected = '';
  let pos = 0;
  for (const e of edits) {
    assert.ok(e.at >= pos, `replacements overlap at ${JSON.stringify(e.from)}`);
    expected += b.before.slice(pos, e.at) + e.to;
    pos = e.at + e.from.length;
  }
  expected += b.before.slice(pos);
  assert.equal(after, expected, `${b.formulaRel} after update-formula.sh`);
});

// brew-check.sh against a fake Homebrew

Given(P + 'a committed sandbox copy of the repository with an uncommitted line added to {string}', function (rel) {
  const b = base(this);
  b.sandbox = path.join(b.base, 'sandbox');
  fs.mkdirSync(b.sandbox);
  for (const file of listFiles(ROOT, '', new Set(['.git', '.kogen/local', 'node_modules']), [])) {
    fs.mkdirSync(path.dirname(path.join(b.sandbox, file)), { recursive: true });
    fs.copyFileSync(path.join(ROOT, file), path.join(b.sandbox, file));
  }
  git(b.sandbox, ['init', '-q']);
  git(b.sandbox, ['add', '-A']);
  git(b.sandbox, ['commit', '-q', '--no-verify', '--allow-empty', '-m', 'sandbox']);
  fs.mkdirSync(path.dirname(path.join(b.sandbox, rel)), { recursive: true });
  fs.appendFileSync(path.join(b.sandbox, rel), '# kogen-homebrew-tap-20261106 uncommitted marker\n');
  b.markedRel = rel;
});

Given(P + 'a fake Homebrew on PATH with these formulae already installed:', function (table) {
  const b = base(this);
  b.fakebin = path.join(b.base, 'fakebin');
  b.state = path.join(b.base, 'state');
  b.tmp = path.join(b.base, 'tmp');
  for (const d of [b.fakebin, b.state, b.tmp]) fs.mkdirSync(d, { recursive: true });
  fs.writeFileSync(path.join(b.fakebin, 'brew'), FAKE_BREW, { mode: 0o755 });
  fs.writeFileSync(path.join(b.state, 'installed'), table.raw().map((r) => `${r[0]}\n`).join(''));
});

Given(P + 'the fake Homebrew fails {string} with this output:', function (sub, doc) {
  fs.writeFileSync(path.join(this.kght.state, `fail-${sub}`), `${doc}\n`);
});

When(P + 'I run brew-check.sh in the sandbox', function () {
  const b = this.kght;
  for (const f of ['calls', 'tap-dir', 'tapped-formula.rb']) fs.rmSync(path.join(b.state, f), { force: true });
  const outFile = path.join(b.base, 'brew-check.out');
  const fd = fs.openSync(outFile, 'w');
  let res;
  try {
    res = spawnSync('sh', ['scripts/brew-check.sh'], {
      cwd: b.sandbox,
      stdio: ['ignore', fd, fd],
      timeout: 90000,
      env: cleanEnv({ PATH: `${b.fakebin}${path.delimiter}${process.env.PATH}`, KGHT_FAKE_BREW_STATE: b.state, TMPDIR: b.tmp }),
    });
  } finally {
    fs.closeSync(fd);
  }
  const callsPath = path.join(b.state, 'calls');
  b.check = {
    status: res.status,
    error: res.error,
    out: fs.readFileSync(outFile, 'utf8'),
    calls: fs.existsSync(callsPath) ? lineList(fs.readFileSync(callsPath, 'utf8')) : [],
  };
});

function checkReport(b) {
  return `exit ${b.check.status}${b.check.error ? ` (${b.check.error.message})` : ''}; output:\n${b.check.out}\nbrew calls: ${JSON.stringify(b.check.calls)}`;
}

Then(P + 'brew-check.sh exited with status 0', function () {
  assert.equal(this.kght.check.status, 0, `sh scripts/brew-check.sh: ${checkReport(this.kght)}`);
});

Then(P + 'brew-check.sh exited with a non-zero status', function () {
  const s = this.kght.check.status;
  assert.ok(typeof s === 'number' && s !== 0, `sh scripts/brew-check.sh: ${checkReport(this.kght)}`);
});

Then(P + 'the first line of the brew-check output is {string}', function (want) {
  assert.equal(lineList(this.kght.check.out)[0], want, `first output line; ${checkReport(this.kght)}`);
});

Then(P + 'the last line of the brew-check output is {string}', function (want) {
  const lines = lineList(this.kght.check.out);
  assert.equal(lines[lines.length - 1], want, `last output line; ${checkReport(this.kght)}`);
});

Then(P + 'the brew-check output contains {string}', function (want) {
  assert.ok(this.kght.check.out.includes(want), `output does not contain ${JSON.stringify(want)}; ${checkReport(this.kght)}`);
});

Then(P + 'the fake Homebrew received exactly these commands, in order:', function (table) {
  const b = this.kght;
  const main = b.check.calls.filter((c) => {
    const words = c.split(' ');
    if (!MAIN_COMMANDS.has(words[0])) return false;
    if (words[0] === 'tap' && words.length === 1) return false;
    return !words.some((w) => w.startsWith('--json'));
  });
  const sandbox = fs.realpathSync(b.sandbox);
  const shown = main.map((c) => {
    const m = c.match(/^tap kogenai\/tap (\/.+)$/);
    if (!m) return c;
    const dir = fs.existsSync(m[1]) ? fs.realpathSync(m[1]) : m[1];
    const inside = dir === sandbox || dir.startsWith(sandbox + path.sep);
    return inside ? `tap kogenai/tap ${m[1]} (the sandbox itself, not a temporary copy)` : 'tap kogenai/tap <temporary copy>';
  });
  assert.deepEqual(shown, table.raw().map((r) => r[0]), `main brew commands in order; ${checkReport(b)}`);
});

Then(P + 'the formula the fake Homebrew tapped is the sandbox working-tree formula with the uncommitted line', function () {
  const b = this.kght;
  const tapped = path.join(b.state, 'tapped-formula.rb');
  assert.ok(fs.existsSync(tapped), `the fake Homebrew was never asked to tap kogenai/tap; ${checkReport(b)}`);
  const working = fs.readFileSync(path.join(b.sandbox, b.markedRel), 'utf8');
  assert.equal(fs.readFileSync(tapped, 'utf8'), working, `HEAD:${b.markedRel} of the tapped directory against the sandbox working tree`);
});

Then(P + 'the temporary copy no longer exists', function () {
  const b = this.kght;
  const rec = path.join(b.state, 'tap-dir');
  assert.ok(fs.existsSync(rec), `the fake Homebrew never tapped a directory; ${checkReport(b)}`);
  const dir = fs.readFileSync(rec, 'utf8').trim();
  assert.ok(!fs.existsSync(dir), `${dir} still exists after brew-check.sh`);
});

Then(P + 'the fake Homebrew has no tap and no trusted tap', function () {
  const b = this.kght;
  for (const f of ['taps', 'trusted']) {
    const p = path.join(b.state, f);
    const entries = fs.existsSync(p) ? lineList(fs.readFileSync(p, 'utf8')) : [];
    assert.deepEqual(entries, [], `fake Homebrew ${f} after brew-check.sh; ${checkReport(b)}`);
  }
});

Then(P + 'the fake Homebrew installed formulae are exactly:', function (table) {
  const b = this.kght;
  const installed = lineList(fs.readFileSync(path.join(b.state, 'installed'), 'utf8')).sort();
  assert.deepEqual(installed, table.raw().map((r) => r[0]).sort(), `fake Homebrew installed formulae after brew-check.sh; ${checkReport(b)}`);
});
