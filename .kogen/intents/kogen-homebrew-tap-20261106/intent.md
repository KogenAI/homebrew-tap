# Add the Kogen formula, its updater and brew check

Slug: kogen-homebrew-tap-20261106
Model: not applicable — a formula file, two linear shell scripts and documentation; brew-check.sh is one fixed step sequence with an always-run cleanup, exercised end to end by scenarios against a fake Homebrew
Acceptance:
- .kogen/intents/kogen-homebrew-tap-20261106/acceptance.feature
- features/steps/kogen-homebrew-tap-20261106__steps.js
- features/steps/kogen-homebrew-tap-20261106__controls.js

The tap KogenAI/homebrew-tap gets the formula behind `brew install kogenai/tap/kogen`, the one script a release pipeline calls to point the formula at a new release, and the repository's check that runs the real Homebrew on the formula. The tap currently has no formula, no scripts and no NOTICE; nothing existing is replaced except the README text. The build adds exactly `Formula/kogen.rb`, `scripts/update-formula.sh`, `scripts/brew-check.sh` and `NOTICE`, and edits `README.md`. It adds no other file outside `.kogen/` and `features/`, supports no older formula, and never edits `.kogen/project.yaml` or `.kogen/models.yaml` (the configured check `brew-formula` already runs `sh scripts/brew-check.sh` when that file exists).

Acceptance (cucumber) only reads files and runs the two scripts with fakes: `update-formula.sh` on a temporary copy, and `brew-check.sh` with a fake `brew` first on PATH. It never runs the real brew, never taps and never downloads a release. The real `brew style`, `brew audit --strict`, `brew install` and `brew test` run only inside `scripts/brew-check.sh`, which Kogen runs as the repository's check. `features/steps/kogen-homebrew-tap-20261106__controls.js` holds the observer controls named under Feasibility; it registers no steps.

### Release facts the formula uses

The published release `v0.1.0-dev.47236bbb` of KogenAI/kogen lists `install-kogen.sh`, `SHA256SUMS` and the archives `kogen-v0.1.0-dev.47236bbb-<os>-<arch>.tar.gz` for `darwin-arm64`, `darwin-x86_64`, `linux-arm64` and `linux-x86_64`. Archive names carry the tag with its leading `v`, and Linux x86-64 is spelled `linux-x86_64`. Its SHA256SUMS lines for the two supported archives are:

```
2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c  kogen-v0.1.0-dev.47236bbb-darwin-arm64.tar.gz
3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0  kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz
```

Download URL pattern: `https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz`, where `<version>` is the tag, for example `v0.1.0-dev.47236bbb`. Each archive has one top-level directory containing `bin/kogen`, `lib/` (VERSION, VERSION.json, cucumber/, quint/), `docs/`, `licenses/`, `LICENSE`, `NOTICE`, `README.md`, `install.sh` and `TARGET`. Its install.sh copies `bin docs lib licenses README.md LICENSE NOTICE` into `<prefix>/lib/kogen/`. It writes the path of a Node 22+ binary into `<prefix>/lib/kogen/node-path` and links `<prefix>/bin/kogen` to `<prefix>/lib/kogen/bin/kogen`. `kogen version` prints `kogen v0.1.0-dev.47236bbb (2026-11-06)`.

### Formula/kogen.rb

- `class Kogen < Formula` with `desc "Takes one requested feature through shaping, building, verifying and committing"`, `homepage "https://kogen.dev"` and `license "Apache-2.0"`.
- Top level: `url` of the `linux-x86_64` archive, then `version "0.1.0-dev.47236bbb"`, then `sha256` of that archive. An explicit `version` is required: Homebrew 7.0.12 parses these archive URLs as version `86.64` / `64`.
- `depends_on "node"`.
- `on_macos do` holds `depends_on arch: :arm64` and an `on_arm do` block with the `url` and `sha256` of the `darwin-arm64` archive.
- `on_linux do` holds `depends_on arch: :x86_64`.
- This shape is required because, while tapping, Homebrew 7.0.12 loads the formula for every OS and arch and refused a formula that had no url on Intel macOS and arm64 Linux (`formula requires at least a URL`). `url` and `sha256` directly inside `on_macos`/`on_linux` are rejected by `brew style`/`brew audit`, but inside `on_arm` they are allowed. With `depends_on arch:`, only macOS arm64 and Linux x86-64 can install.
- Each archive URL appears exactly once, on its own `url "…"` line. The next `sha256 "…"` line after it, before any other `url` line, carries that archive's SHA256SUMS checksum.
- `def install`: install `bin`, `docs`, `lib`, `licenses`, `README.md`, `LICENSE` and `NOTICE` from the staged archive into `lib/"kogen"`, which is the install.sh layout. Write `lib/"kogen/node-path"` containing `#{formula_opt_bin("node")}/node` and a newline, and `bin.install_symlink lib/"kogen/bin/kogen"`. `install.sh` and `TARGET` are not installed. Kogen reads `node-path` to run Quint and the acceptance bridge, so the formula depends on Homebrew's node instead of install.sh's PATH lookup or Node download.
- `test do` runs `#{bin}/kogen version` and asserts that the output matches `v#{version}`.
- The formula must pass `brew style` and `brew audit --strict`, which the check runs. Component order and helper names follow what `brew style` demands, for example `formula_opt_bin("node")` rather than `Formula["node"].opt_bin`.

### scripts/update-formula.sh

- Run as `sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>`, where `<version>` is the release tag as it appears in archive names (for example `v0.2.0-dev.0123abcd`). `<sha256-arm64>` is the SHA256SUMS checksum of the `darwin-arm64` archive and `<sha256-linux-amd64>` that of the `linux-x86_64` archive.
- Line 1 is a `#` comment documenting the contract ID `kogen/release-archive`. It names the URL pattern `https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz` and `SHA256SUMS`, one line `<sha256>  kogen-<version>-<os>-<arch>.tar.gz` per archive. There is no shebang line: the script runs with `sh`.
- It edits, in place, `Formula/kogen.rb` of the repository that contains the script, found from the script's own path (`$(dirname "$0")/../Formula/kogen.rb`):
  - the `darwin-arm64` url becomes the pattern URL for `<version>` and `darwin-arm64`, and its sha256 becomes `<sha256-arm64>`;
  - the `linux-x86_64` url becomes the pattern URL for `<version>` and `linux-x86_64`, and its sha256 becomes `<sha256-linux-amd64>`;
  - the `version` line becomes `<version>` without its leading `v`.
- Every other byte stays the same. It exits 0 and works again on its own output, release after release. Example: `v0.2.0-dev.0123abcd` turns `version "0.1.0-dev.47236bbb"` into `version "0.2.0-dev.0123abcd"`.

### scripts/brew-check.sh

`sh scripts/brew-check.sh`, with the repository root as the current directory. POSIX sh, since the configured check runs it with `sh`. It uses the `brew` on PATH, never an absolute brew path, and exports `HOMEBREW_NO_AUTO_UPDATE=1`. Steps, in this order, each with its name:

1. `copy`: into a new temporary directory (`mktemp -d`, so it honours `TMPDIR`), copy every file that `git ls-files --cached --others --exclude-standard` lists and that exists. That is the working tree, including uncommitted changes and untracked files that are not ignored. Then `git init`, `git add -A` and commit there, without depending on the user's Git identity, signing configuration or hooks. Brew refuses a formula path outside a tap, and tapping a commit-free checkout would check HEAD instead of the working tree.
2. `list`: `brew list --formula`, kept as the snapshot of formulae installed before the run.
3. `tap`: `brew tap kogenai/tap <temporary copy>`.
4. `trust`: `brew trust --tap kogenai/tap`. Homebrew 7.0.12 refuses to load a formula from an untrusted tap (`Refusing to load formula kogenai/tap/kogen from untrusted tap`), and `brew trust --help` documents `--tap`. Run after tapping, it records the tap's remote path, so the user's own trust entries are not touched.
5. `style`: `brew style kogenai/tap/kogen`.
6. `audit`: `brew audit --strict kogenai/tap/kogen`.
7. `install`: `brew install kogenai/tap/kogen`.
8. `test`: `brew test kogenai/tap/kogen`.

The first failing step stops the sequence. Cleanup then always runs for the steps that ran, in this order:

- if `list` ran, run `brew list --formula` again and `brew uninstall` every formula not in the snapshot: kogen and the dependencies this run installed. Formulae installed before the run stay.
- if `trust` ran, `brew untrust --tap kogenai/tap`. This comes before untap, because it resolves the tap name to its remote.
- if `tap` ran, `brew untap kogenai/tap`.
- remove the temporary directory.

After cleanup no tap, trust entry, temporary copy or newly installed formula is left, so a second run starts clean.

Output: each step's output is captured, not streamed.

- When a step fails, the first line the script prints is `brew-check: failed at <step>`, followed by that step's captured output.
- When cleanup fails, it prints `brew-check: failed at cleanup` and the cleanup output.
- The script exits non-zero on any failure.
- When every step and the cleanup succeed, the last line is `brew-check: passed` and the exit status is 0.

On a host where Homebrew has no usable bottles (a non-default prefix), node and its dependencies may be built from source on every run, because cleanup uninstalls them. This Intent makes no claim about how long the check takes on any host.

### NOTICE and README.md

- `NOTICE` is kogen.dev's NOTICE wording, exactly these four lines: `Kogen`, `Copyright 2026 Optimum Tech, LLC`, an empty line, `Licensed under the Apache License, Version 2.0.`
- `README.md` keeps the `# Kogen Homebrew tap` heading and states:
  - the one install command `brew install kogenai/tap/kogen`; it is the only README line containing `brew install`;
  - what the formula installs: Kogen `v0.1.0-dev.47236bbb` for macOS arm64 and Linux x86-64, `bin/kogen` and `lib/kogen` as install.sh lays them out, with Homebrew's node;
  - how a release updates the tap: take the `darwin-arm64` and `linux-x86_64` lines of the release's `SHA256SUMS`, run `sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>` and commit `Formula/kogen.rb`.

## Decisions
- The install command is `brew install kogenai/tap/kogen` (source: request)
- The formula supports only macOS arm64 and Linux x86-64 and installs the release archive's contents with the install.sh layout (source: request)
- The first formula names the latest published release v0.1.0-dev.47236bbb, and the README says how to bump it (source: request)
- A release updates the tap only through `scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>`, whose first line documents the contract ID `kogen/release-archive` (source: request)
- brew-check.sh prints the failing step first, exits non-zero on any failure and leaves nothing installed or tapped, so a second run starts clean (source: request)
- NOTICE carries the line "Copyright 2026 Optimum Tech, LLC" in kogen.dev's wording (source: request)

## Source comparison
- Archive names `kogen-<version>-<os>-<arch>.tar.gz` with "linux-amd64" (request) conflict with the published release, whose names are `kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz` and `…-darwin-arm64.tar.gz`. The formula uses the published names, `<version>` is the v-prefixed tag, and the update script keeps the request's argument name `<sha256-linux-amd64>` for the linux-x86_64 checksum (Formula/kogen.rb, scripts/update-formula.sh, acceptance scenarios 1 and 3).
- "taps the checkout locally (`brew tap kogenai/tap "$PWD"`)" (request item 3) is superseded by delivery note rule 3: tap a committed temporary copy of the working tree (brew-check.sh step `copy`, acceptance scenario 4).
- "runs `brew style` and `brew audit --strict` …, `brew install` and `brew test`" (request item 3) is addressed with `brew trust --tap kogenai/tap` added before style and audit, per delivery note rule 3 (acceptance scenarios 4 to 6).
- "untaps and uninstalls what it installed" (request item 3) is addressed as: uninstall every formula the run added, compared with a `brew list --formula` snapshot, then untrust and untap (acceptance scenarios 4 and 6).
- "prints the failing step first" (request item 3) is addressed as the first output line `brew-check: failed at <step>` (acceptance scenarios 5 and 6).
- Synthetic acceptance 1 and 3 (real `brew audit --strict`, `brew style`, install, test, `kogen version` prints the version) are checked by the configured check `brew-formula` (`sh scripts/brew-check.sh`) and statically by acceptance scenario 1. Per delivery note rule 2, acceptance never runs brew.
- Synthetic acceptance 2 (update-formula.sh changes only url, sha256 and version) is covered by acceptance scenario 3, for two consecutive releases.
- Synthetic acceptance 4 and request items 4 and 5 (NOTICE, README) are covered by acceptance scenarios 7 and 8. NOTICE wording is copied from kogen.dev's NOTICE.
- Request item 6 (no compatibility with older formulae, no other files) is covered by acceptance scenario 9.
- Constraint "Never edit .kogen/project.yaml or .kogen/models.yaml" is preserved; both stay protected.
- Constraint "The check must pass on both hosts" (eu2 Linuxbrew, MacBook ~/homebrew) is not executable in acceptance. The configured check runs brew-check.sh on whichever host runs it, and this Intent claims no host result.
- Formula dependency on Homebrew's `node`, which writes `lib/kogen/node-path`, is not named in the request. It is required by the install.sh layout's `node-path`, which Kogen reads.

## Tests
- The formula names the darwin-arm64 and linux-x86_64 archive URLs of v0.1.0-dev.47236bbb, each followed by its SHA256SUMS checksum, plus `version`, the node and arch dependencies, `node-path` and a `kogen version` test: acceptance scenario "The formula installs Kogen v0.1.0-dev.47236bbb for macOS arm64 and Linux x86-64" (integration)
- The formula passes real `brew style`, `brew audit --strict`, `brew install` and `brew test`: configured check `brew-formula` running scripts/brew-check.sh (existing)
- update-formula.sh line 1 documents `kogen/release-archive`, the URL pattern and SHA256SUMS: acceptance scenario "update-formula.sh documents the kogen/release-archive contract on its first line" (integration)
- update-formula.sh rewrites only the two url lines, the two sha256 lines and the version, for two consecutive releases: acceptance scenario "update-formula.sh rewrites only the url, sha256 and version lines, release after release" (integration)
- brew-check.sh taps a committed temporary copy of the working tree including uncommitted changes, trusts it before style, audit, install and test, uninstalls only what the run installed, untrusts, untaps and passes again on a second run: acceptance scenario "brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes" (scenario)
- A failing audit is reported on the first output line, stops install and test, and cleanup still runs: acceptance scenario "brew-check.sh reports a failing audit first, skips install and test, and still cleans up" (scenario)
- A failing brew test is reported on the first output line, and cleanup removes kogen but keeps formulae installed before the run: acceptance scenario "brew-check.sh reports a failing brew test first and uninstalls only what the run installed" (scenario)
- NOTICE has kogen.dev's wording with "Copyright 2026 Optimum Tech, LLC": acceptance scenario "NOTICE carries kogen.dev's notice wording" (integration)
- README names the one install command, what is installed and the update-formula.sh/SHA256SUMS release step: acceptance scenario "README gives the one install command, what it installs and how a release updates the formula" (integration)
- No other files are added: acceptance scenario "The tap adds only the formula, its two scripts and NOTICE" (integration)

## Feasibility
- evidence: {"id": "brew-check-tapped-copy", "kind": "observer", "inputs": ["features/steps/kogen-homebrew-tap-20261106__controls.js", ".kogen/intents/kogen-homebrew-tap-20261106/acceptance.feature"], "observers": ["features/steps/kogen-homebrew-tap-20261106__steps.js"], "checks": [{"name": "good", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js brew-check-good 'brew-check.sh'", "exit": 0, "output": "PASSED brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes\nPASSED brew-check.sh reports a failing audit first, skips install and test, and still cleans up\nPASSED brew-check.sh reports a failing brew test first and uninstalls only what the run installed\n"}, {"name": "bad", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js brew-check-bad-head 'brew-check.sh'", "exit": 1, "output": "FAILED brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes\n  at: kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:\nFAILED brew-check.sh reports a failing audit first, skips install and test, and still cleans up\n  at: kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:\nFAILED brew-check.sh reports a failing brew test first and uninstalls only what the run installed\n  at: kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:\n"}]}
- evidence: {"id": "brew-check-dependency-cleanup", "kind": "observer", "inputs": ["features/steps/kogen-homebrew-tap-20261106__controls.js", ".kogen/intents/kogen-homebrew-tap-20261106/acceptance.feature"], "observers": ["features/steps/kogen-homebrew-tap-20261106__steps.js"], "checks": [{"name": "good", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js brew-check-good 'brew-check.sh'", "exit": 0, "output": "PASSED brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes\nPASSED brew-check.sh reports a failing audit first, skips install and test, and still cleans up\nPASSED brew-check.sh reports a failing brew test first and uninstalls only what the run installed\n"}, {"name": "bad", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js brew-check-bad-deps 'brew-check.sh'", "exit": 1, "output": "FAILED brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes\n  at: kogen-homebrew-tap-20261106: the fake Homebrew installed formulae are exactly:\nPASSED brew-check.sh reports a failing audit first, skips install and test, and still cleans up\nPASSED brew-check.sh reports a failing brew test first and uninstalls only what the run installed\n"}]}
- evidence: {"id": "update-formula-second-release", "kind": "observer", "inputs": ["features/steps/kogen-homebrew-tap-20261106__controls.js", ".kogen/intents/kogen-homebrew-tap-20261106/acceptance.feature"], "observers": ["features/steps/kogen-homebrew-tap-20261106__steps.js"], "checks": [{"name": "good", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js update-good '^update-formula.sh rewrites'", "exit": 0, "output": "PASSED update-formula.sh rewrites only the url, sha256 and version lines, release after release\n"}, {"name": "bad", "command": "\"$KOGEN_NODE\" features/steps/kogen-homebrew-tap-20261106__controls.js update-bad '^update-formula.sh rewrites'", "exit": 1, "output": "FAILED update-formula.sh rewrites only the url, sha256 and version lines, release after release\n  at: kogen-homebrew-tap-20261106: the copied formula equals the formula before that run with these replacements:\n"}]}
