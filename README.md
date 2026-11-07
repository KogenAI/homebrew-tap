# Kogen Homebrew tap

Homebrew tap for Kogen.

## Install

```
brew install kogenai/tap/kogen
```

The formula installs Kogen `v0.1.0-dev.47236bbb` for macOS arm64 and Linux x86-64. It lays out
`bin/kogen` and `lib/kogen` the way the release's `install.sh` does, and runs Kogen with Homebrew's node.

## Updating the formula for a release

1. Take the `darwin-arm64` and `linux-x86_64` lines of the release's `SHA256SUMS`.
2. Run `sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>`, where `<version>`
   is the release tag as it appears in archive names, for example `v0.2.0-dev.0123abcd`.
3. Commit `Formula/kogen.rb`.

`sh scripts/brew-check.sh` runs the real Homebrew's style, audit, install and test on the formula, then
removes the tap and everything it installed.
