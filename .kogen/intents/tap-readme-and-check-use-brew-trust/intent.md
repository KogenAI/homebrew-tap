# Use brew trust in the tap README and brew check

Slug: tap-readme-and-check-use-brew-trust
Model: not applicable — the change is documentation text and a straight-line shell script with no state worth modelling
Acceptance:
- .kogen/intents/tap-readme-and-check-use-brew-trust/acceptance.feature
- features/steps/tap-readme-and-check-use-brew-trust__steps.js

Homebrew 7 refuses to load a formula from a third-party tap that has not been trusted: `brew install kogenai/tap/kogen` on a fresh Homebrew 7 fails with "Refusing to load formula kogenai/tap/kogen from untrusted tap". The documented install becomes the two commands `brew trust kogenai/tap && brew install kogenai/tap/kogen` (verified on Homebrew 7.0.12: `brew trust kogenai/tap` trusts the tap by name), and `scripts/brew-check.sh` runs that same user sequence.

`README.md` is rewritten short and task-first, at most 25 lines: one sentence on what the tap is, the exact install line `brew trust kogenai/tap && brew install kogenai/tap/kogen` on one line, one sentence saying why (Homebrew 7 does not load formulae from third-party taps until the tap is trusted), how to update (`brew upgrade kogen`), and one line on how a release updates the formula. It names no release version anywhere, so a release never needs to touch it. This replaces the current README text, including the single `brew install kogenai/tap/kogen` command and the sentence naming a release version.

`scripts/brew-check.sh` runs the user sequence against the committed temporary copy tapped as kogenai/tap: `brew tap` of the copy, then `brew trust kogenai/tap` (the tap by name, not `--tap`), then `brew install kogenai/tap/kogen`, then `brew test kogenai/tap/kogen`, then it removes what it added, with `brew untrust` before `brew untap`. Style and audit still run. A Homebrew without a `brew trust` subcommand skips the trust step. This replaces the script's current `--tap` form of trust and untrust.

The release process, `Formula/kogen.rb`, `scripts/update-formula.sh` and the project configuration are not changed.

## Decisions
- README.md is at most 25 lines with one tap sentence, the one-line install `brew trust kogenai/tap && brew install kogenai/tap/kogen`, one why sentence, `brew upgrade kogen`, one release line, and no release version (decision: D1, round 1) (evidence: README.md) (source: request)
- brew-check.sh runs tap, trust by name, style, audit, install, test, uninstalls what it installed, then untrust before untap (decision: D2, round 1) (evidence: scripts/brew-check.sh) (source: request)
- A Homebrew lacks brew trust when `brew trust --help` exits non-zero; trust and untrust are then skipped (decision: D3, round 1) (evidence: scripts/brew-check.sh) (assumption: No Homebrew is installed in this checkout, so the exit status of `brew trust --help` on a Homebrew without trust is unconfirmed.) (source: request)
- The untrust form (name or --tap) is not pinned; acceptance normalizes both (decision: D4, round 1) (evidence: scripts/brew-check.sh) (assumption: Which brew untrust form works on Homebrew 7 was not verified.) (source: request)
- Acceptance uses literal fake brew and sandbox repository fixtures written by the step file (decision: D5, round 1) (evidence: features/steps/kogen-homebrew-tap-20261106__steps.js) (source: request)

## Source comparison
- Request item 1 (README: two-command install on one line, one why sentence, no release version) is addressed by acceptance scenarios "README.md shows the two-command install on one line and says why" and "README.md names no release version"; the stronger check that no `x.y.z` version appears at all follows from "no longer names a release version anywhere".
- Request item 2 (brew-check.sh sequence, untrust before untap, style and audit still run, skip without `brew trust`) is addressed by the scenarios "brew-check.sh runs the user's install sequence on the tapped copy and cleans up" and "brew-check.sh skips the trust step on a Homebrew without brew trust".
- Acceptance 2 (a fake whose install fails unless trust ran first; the same fake fails the old script) is addressed by the scenario "brew-check.sh passes only because it trusts the tap before installing"; the fake rejects `brew trust --tap`, so the old script fails against it, and the controls overlay a script without the trust step.
- Acceptance 4 is addressed by the no-trust scenario. The concise-docs rule (at most 25 lines, task-first, `brew upgrade kogen`, one line on the release) is addressed by the scenario "README.md is short and says how to update".
- Superseded: the earlier Intent kogen-homebrew-tap-20261106 required `trust --tap`/`untrust --tap` in brew-check.sh and a README that names a release version and has `brew install` as its only install line. Its scenarios on those points no longer describe the product; this Intent's acceptance is the contract for them.

## Tests
- brew-check.sh runs tap, trust by name, style, audit, install, test, then untrust before untap, and leaves nothing behind: scenario "brew-check.sh runs the user's install sequence on the tapped copy and cleans up" (scenario)
- brew-check.sh needs the trust step to get past a Homebrew that refuses untrusted taps: scenario "brew-check.sh passes only because it trusts the tap before installing" (scenario)
- brew-check.sh skips trust and untrust on a Homebrew without `brew trust` and still runs the rest: scenario "brew-check.sh skips the trust step on a Homebrew without brew trust" (scenario)
- README.md shows the two-command install on one line with the reason: scenario "README.md shows the two-command install on one line and says why" (scenario)
- README.md names no release version: scenario "README.md names no release version" (scenario)
- README.md has at most 25 lines and says how to update: scenario "README.md is short and says how to update" (scenario)

## Feasibility
- none
