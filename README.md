# Kogen Homebrew tap

Homebrew tap for Kogen, a tool that runs on macOS arm64 and Linux x86-64.

## Install

```
brew trust kogenai/tap && brew install kogenai/tap/kogen
```

Homebrew 7 does not load formulae from third-party taps until the tap is trusted.

Update with `brew upgrade kogen`.

A release updates the formula with `sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>`.
