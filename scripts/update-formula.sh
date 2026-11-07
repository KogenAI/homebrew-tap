# Contract kogen/release-archive: archives at https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz, checksums in SHA256SUMS, one line "<sha256>  kogen-<version>-<os>-<arch>.tar.gz" per archive.
# Usage: sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>
# <version> is the release tag (for example v0.2.0-dev.0123abcd); the checksums are the SHA256SUMS
# lines of the darwin-arm64 and linux-x86_64 archives. Rewrites Formula/kogen.rb in place.
set -eu

if [ $# -ne 3 ]; then
  echo "usage: sh scripts/update-formula.sh <version> <sha256-arm64> <sha256-linux-amd64>" >&2
  exit 2
fi

formula="$(dirname "$0")/../Formula/kogen.rb"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

awk -v tag="$1" -v arm64="$2" -v amd64="$3" '
  BEGIN {
    base = "https://github.com/KogenAI/kogen/releases/download/" tag "/kogen-" tag "-"
    ver = tag
    sub(/^v/, "", ver)
  }
  {
    indent = $0
    sub(/[^ \t].*$/, "", indent)
  }
  /^[ \t]*url "[^"]*-darwin-arm64\.tar\.gz"/ { print indent "url \"" base "darwin-arm64.tar.gz\""; sha = arm64; next }
  /^[ \t]*url "[^"]*-linux-x86_64\.tar\.gz"/ { print indent "url \"" base "linux-x86_64.tar.gz\""; sha = amd64; next }
  /^[ \t]*url "/ { sha = "" }
  sha != "" && /^[ \t]*sha256 "/ { print indent "sha256 \"" sha "\""; sha = ""; next }
  /^[ \t]*version "/ { print indent "version \"" ver "\""; next }
  { print }
' "$formula" >"$tmp"
cat "$tmp" >"$formula"
