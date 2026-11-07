'use strict';
// Observer controls for the kogen-homebrew-tap-20261106 steps. Loaded by cucumber it does nothing; run as
//   "$KOGEN_NODE" features/steps/kogen-homebrew-tap-20261106__controls.js <fixture> <scenario-name-regex>
// it writes COMMON and one known-good or known-bad fixture into a temporary directory, runs the matching
// acceptance scenarios there with the Intent's step file, and prints each scenario's result (and the first
// step that did not pass). Exit status is cucumber's.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const COMMON = {
  "Formula/kogen.rb": "class Kogen < Formula\n  desc \"Turns feature requests into verified, committed changes\"\n  homepage \"https://kogen.dev\"\n  url \"https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz\"\n  version \"0.1.0-dev.47236bbb\"\n  sha256 \"3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0\"\n  license \"Apache-2.0\"\n\n  depends_on \"node\"\n\n  on_macos do\n    depends_on arch: :arm64\n\n    on_arm do\n      url \"https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-darwin-arm64.tar.gz\"\n      sha256 \"2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c\"\n    end\n  end\n\n  on_linux do\n    depends_on arch: :x86_64\n  end\n\n  def install\n    (lib/\"kogen\").install \"bin\", \"docs\", \"lib\", \"licenses\", \"README.md\", \"LICENSE\", \"NOTICE\"\n    (lib/\"kogen/node-path\").write \"#{formula_opt_bin(\"node\")}/node\\n\"\n    bin.install_symlink lib/\"kogen/bin/kogen\"\n  end\n\n  test do\n    assert_match \"v#{version}\", shell_output(\"#{bin}/kogen version\")\n  end\nend\n"
};

const FIXTURES = {
  "brew-check-good": {
    "scripts/brew-check.sh": "# Known-good control: taps a committed copy of the working tree, trusts it, runs style, audit, install\n# and test, then uninstalls what the run installed, untrusts and untaps.\nset -u\nexport HOMEBREW_NO_AUTO_UPDATE=1\nwork=$(mktemp -d) || exit 1\ncopy=\"$work/tap\"\nlog=\"$work/log\"\nlisted=0 tapped=0 trusted=0\n\nstep() {\n  name=$1\n  shift\n  \"$@\" >\"$log\" 2>&1 && return 0\n  printf 'brew-check: failed at %s\\n' \"$name\"\n  cat \"$log\"\n  return 1\n}\n\ncopy_tree() {\n  mkdir \"$copy\" && git ls-files --cached --others --exclude-standard >\"$work/files\" || return 1\n  while IFS= read -r f; do\n    [ -f \"$f\" ] || continue\n    mkdir -p \"$copy/$(dirname \"$f\")\" && cp -p \"$f\" \"$copy/$f\" || return 1\n  done <\"$work/files\"\n  git -C \"$copy\" init -q && git -C \"$copy\" add -A &&\n    git -C \"$copy\" -c user.name=brew-check -c user.email=brew-check@localhost -c commit.gpgsign=false commit -q --no-verify -m \"brew-check working tree\"\n}\n\nsnapshot() { brew list --formula >\"$work/before\"; }\n\nmain() {\n  step copy copy_tree || return 1\n  step list snapshot || return 1\n  listed=1\n  step tap brew tap kogenai/tap \"$copy\" || return 1\n  tapped=1\n  step trust brew trust --tap kogenai/tap || return 1\n  trusted=1\n  step style brew style kogenai/tap/kogen || return 1\n  step audit brew audit --strict kogenai/tap/kogen || return 1\n  step install brew install kogenai/tap/kogen || return 1\n  step test brew test kogenai/tap/kogen || return 1\n}\n\nremove_new() {\n  brew list --formula >\"$work/after\" || return 1\n  new=$(grep -vxF -f \"$work/before\" \"$work/after\")\n  [ -z \"$new\" ] || brew uninstall $new\n}\n\ncleanup() {\n  ok=0\n  if [ \"$listed\" = 1 ]; then step cleanup remove_new || ok=1; fi\n  if [ \"$trusted\" = 1 ]; then step cleanup brew untrust --tap kogenai/tap || ok=1; fi\n  if [ \"$tapped\" = 1 ]; then step cleanup brew untap kogenai/tap || ok=1; fi\n  return $ok\n}\n\nstatus=0\nmain || status=1\ncleanup || status=1\nrm -rf \"$work\"\n[ \"$status\" = 0 ] && echo \"brew-check: passed\"\nexit $status\n"
  },
  "brew-check-bad-head": {
    "scripts/brew-check.sh": "# Known-bad control: taps the checkout itself (its HEAD, not the working tree); otherwise the known-good\n# control.\nset -u\nexport HOMEBREW_NO_AUTO_UPDATE=1\nwork=$(mktemp -d) || exit 1\ncopy=\"$work/tap\"\nlog=\"$work/log\"\nlisted=0 tapped=0 trusted=0\n\nstep() {\n  name=$1\n  shift\n  \"$@\" >\"$log\" 2>&1 && return 0\n  printf 'brew-check: failed at %s\\n' \"$name\"\n  cat \"$log\"\n  return 1\n}\n\ncopy_tree() {\n  mkdir \"$copy\" && git ls-files --cached --others --exclude-standard >\"$work/files\" || return 1\n  while IFS= read -r f; do\n    [ -f \"$f\" ] || continue\n    mkdir -p \"$copy/$(dirname \"$f\")\" && cp -p \"$f\" \"$copy/$f\" || return 1\n  done <\"$work/files\"\n  git -C \"$copy\" init -q && git -C \"$copy\" add -A &&\n    git -C \"$copy\" -c user.name=brew-check -c user.email=brew-check@localhost -c commit.gpgsign=false commit -q --no-verify -m \"brew-check working tree\"\n}\n\nsnapshot() { brew list --formula >\"$work/before\"; }\n\nmain() {\n  step copy copy_tree || return 1\n  step list snapshot || return 1\n  listed=1\n  step tap brew tap kogenai/tap \"$PWD\" || return 1\n  tapped=1\n  step trust brew trust --tap kogenai/tap || return 1\n  trusted=1\n  step style brew style kogenai/tap/kogen || return 1\n  step audit brew audit --strict kogenai/tap/kogen || return 1\n  step install brew install kogenai/tap/kogen || return 1\n  step test brew test kogenai/tap/kogen || return 1\n}\n\nremove_new() {\n  brew list --formula >\"$work/after\" || return 1\n  new=$(grep -vxF -f \"$work/before\" \"$work/after\")\n  [ -z \"$new\" ] || brew uninstall $new\n}\n\ncleanup() {\n  ok=0\n  if [ \"$listed\" = 1 ]; then step cleanup remove_new || ok=1; fi\n  if [ \"$trusted\" = 1 ]; then step cleanup brew untrust --tap kogenai/tap || ok=1; fi\n  if [ \"$tapped\" = 1 ]; then step cleanup brew untap kogenai/tap || ok=1; fi\n  return $ok\n}\n\nstatus=0\nmain || status=1\ncleanup || status=1\nrm -rf \"$work\"\n[ \"$status\" = 0 ] && echo \"brew-check: passed\"\nexit $status\n"
  },
  "brew-check-bad-deps": {
    "scripts/brew-check.sh": "# Known-bad control: cleanup uninstalls only kogen, leaving dependencies the run installed; otherwise\n# the known-good control.\nset -u\nexport HOMEBREW_NO_AUTO_UPDATE=1\nwork=$(mktemp -d) || exit 1\ncopy=\"$work/tap\"\nlog=\"$work/log\"\nlisted=0 tapped=0 trusted=0\n\nstep() {\n  name=$1\n  shift\n  \"$@\" >\"$log\" 2>&1 && return 0\n  printf 'brew-check: failed at %s\\n' \"$name\"\n  cat \"$log\"\n  return 1\n}\n\ncopy_tree() {\n  mkdir \"$copy\" && git ls-files --cached --others --exclude-standard >\"$work/files\" || return 1\n  while IFS= read -r f; do\n    [ -f \"$f\" ] || continue\n    mkdir -p \"$copy/$(dirname \"$f\")\" && cp -p \"$f\" \"$copy/$f\" || return 1\n  done <\"$work/files\"\n  git -C \"$copy\" init -q && git -C \"$copy\" add -A &&\n    git -C \"$copy\" -c user.name=brew-check -c user.email=brew-check@localhost -c commit.gpgsign=false commit -q --no-verify -m \"brew-check working tree\"\n}\n\nsnapshot() { brew list --formula >\"$work/before\"; }\n\nmain() {\n  step copy copy_tree || return 1\n  step list snapshot || return 1\n  listed=1\n  step tap brew tap kogenai/tap \"$copy\" || return 1\n  tapped=1\n  step trust brew trust --tap kogenai/tap || return 1\n  trusted=1\n  step style brew style kogenai/tap/kogen || return 1\n  step audit brew audit --strict kogenai/tap/kogen || return 1\n  step install brew install kogenai/tap/kogen || return 1\n  step test brew test kogenai/tap/kogen || return 1\n}\n\nremove_new() {\n  brew list --formula >\"$work/after\" || return 1\n  new=$(grep -vxF -f \"$work/before\" \"$work/after\")\n  brew uninstall kogen\n}\n\ncleanup() {\n  ok=0\n  if [ \"$listed\" = 1 ]; then step cleanup remove_new || ok=1; fi\n  if [ \"$trusted\" = 1 ]; then step cleanup brew untrust --tap kogenai/tap || ok=1; fi\n  if [ \"$tapped\" = 1 ]; then step cleanup brew untap kogenai/tap || ok=1; fi\n  return $ok\n}\n\nstatus=0\nmain || status=1\ncleanup || status=1\nrm -rf \"$work\"\n[ \"$status\" = 0 ] && echo \"brew-check: passed\"\nexit $status\n"
  },
  "update-good": {
    "scripts/update-formula.sh": "# kogen/release-archive: per-release inputs are https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz and the SHA256SUMS lines \"<sha256>  kogen-<version>-<os>-<arch>.tar.gz\"\n# Known-good control: sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>\nset -eu\nversion=$1 arm64=$2 linux=$3\nformula=\"$(cd \"$(dirname \"$0\")/..\" && pwd)/Formula/kogen.rb\"\nbase=\"https://github.com/KogenAI/kogen/releases/download/$version/kogen-$version\"\nawk -v base=\"$base\" -v ver=\"${version#v}\" -v arm=\"$arm64\" -v lin=\"$linux\" '\n  /^ *url \"/ { if ($0 ~ /-darwin-arm64\\.tar\\.gz\"/) { sub(/url \".*\"/, \"url \\\"\" base \"-darwin-arm64.tar.gz\\\"\"); want = arm } else { sub(/url \".*\"/, \"url \\\"\" base \"-linux-x86_64.tar.gz\\\"\"); want = lin } }\n  /^ *sha256 \"/ { sub(/sha256 \".*\"/, \"sha256 \\\"\" want \"\\\"\") }\n  /^ *version \"/ { sub(/version \".*\"/, \"version \\\"\" ver \"\\\"\") }\n  { print }' \"$formula\" >\"$formula.new\"\nmv \"$formula.new\" \"$formula\"\n"
  },
  "update-bad": {
    "scripts/update-formula.sh": "# kogen/release-archive: per-release inputs are https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz and the SHA256SUMS lines \"<sha256>  kogen-<version>-<os>-<arch>.tar.gz\"\n# Known-bad control: replaces only the values of the first release, so a second release changes nothing.\nset -eu\nformula=\"$(cd \"$(dirname \"$0\")/..\" && pwd)/Formula/kogen.rb\"\nsed -e \"s/v0\\.1\\.0-dev\\.47236bbb/$1/g\" -e \"s/\\\"0\\.1\\.0-dev\\.47236bbb\\\"/\\\"${1#v}\\\"/\" \\\n  -e \"s/2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c/$2/\" \\\n  -e \"s/3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0/$3/\" \"$formula\" >\"$formula.new\"\nmv \"$formula.new\" \"$formula\"\n"
  }
};

function summarize(report) {
  const pickles = new Map();
  const pickleSteps = new Map();
  const testSteps = new Map();
  const cases = new Map();
  const started = new Map();
  const first = new Map();
  const lines = [];
  for (const line of fs.readFileSync(report, 'utf8').split('\n')) {
    if (!line) continue;
    const m = JSON.parse(line);
    if (m.pickle) {
      pickles.set(m.pickle.id, m.pickle.name);
      for (const s of m.pickle.steps) pickleSteps.set(s.id, s.text);
    }
    if (m.testCase) {
      cases.set(m.testCase.id, m.testCase.pickleId);
      for (const s of m.testCase.testSteps) testSteps.set(s.id, s.pickleStepId);
    }
    if (m.testCaseStarted) started.set(m.testCaseStarted.id, m.testCaseStarted.testCaseId);
    if (m.testStepFinished) {
      const id = m.testStepFinished.testCaseStartedId;
      const status = m.testStepFinished.testStepResult.status;
      if (status !== 'PASSED' && !first.has(id)) first.set(id, { status, step: pickleSteps.get(testSteps.get(m.testStepFinished.testStepId)) });
    }
    if (m.testCaseFinished) {
      const id = m.testCaseFinished.testCaseStartedId;
      const name = pickles.get(cases.get(started.get(id)));
      const f = first.get(id);
      lines.push(f ? `${f.status} ${name}\n  at: ${f.step || 'a hook'}` : `PASSED ${name}`);
    }
  }
  return lines;
}

function main(fixture, name) {
  if (!FIXTURES[fixture]) throw new Error(`unknown control fixture ${fixture}`);
  const work = fs.mkdtempSync(path.join(os.tmpdir(), 'kght-control-'));
  try {
    for (const [rel, text] of Object.entries({ ...COMMON, ...FIXTURES[fixture] })) {
      fs.mkdirSync(path.dirname(path.join(work, rel)), { recursive: true });
      fs.writeFileSync(path.join(work, rel), text);
    }
    fs.mkdirSync(path.join(work, 'features/steps'), { recursive: true });
    fs.copyFileSync(path.join(__dirname, 'kogen-homebrew-tap-20261106__steps.js'), path.join(work, 'features/steps/kogen-homebrew-tap-20261106__steps.js'));
    fs.copyFileSync(path.join(__dirname, '../../.kogen/intents/kogen-homebrew-tap-20261106/acceptance.feature'), path.join(work, 'acceptance.feature'));
    const report = path.join(work, 'report.ndjson');
    const res = spawnSync(process.execPath, [
      path.join(process.env.KOGEN_CUCUMBER, '@cucumber/cucumber/bin/cucumber.js'),
      '--strict', '--require', 'features/steps/*.js', '--name', name, '--format', `message:${report}`, 'acceptance.feature',
    ], { cwd: work, stdio: 'ignore', env: { ...process.env, NODE_PATH: process.env.KOGEN_CUCUMBER } });
    for (const line of summarize(report)) console.log(line);
    return res.status === null ? 1 : res.status;
  } finally {
    fs.rmSync(work, { recursive: true, force: true });
  }
}

if (require.main === module) process.exitCode = main(process.argv[2], process.argv[3]);
