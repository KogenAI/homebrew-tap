Feature: Kogen Homebrew tap
  `brew install kogenai/tap/kogen` installs Kogen from the GitHub release archive, every release
  updates the formula with scripts/update-formula.sh, and scripts/brew-check.sh checks the formula
  with the Homebrew on PATH. These scenarios read files and run the scripts against a fake Homebrew;
  they never run the real brew and never download a release.

  Scenario: The formula installs Kogen v0.1.0-dev.47236bbb for macOS arm64 and Linux x86-64
    Then kogen-homebrew-tap-20261106: the file "Formula/kogen.rb" has exactly these url lines, each followed by its sha256 line:
      | url                                                                                                                  | sha256                                                           |
      | https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-darwin-arm64.tar.gz | 2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c |
      | https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz | 3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0 |
    And kogen-homebrew-tap-20261106: the file "Formula/kogen.rb" has these lines:
      | class Kogen < Formula        |
      | version "0.1.0-dev.47236bbb" |
      | depends_on "node"            |
      | depends_on arch: :arm64      |
      | depends_on arch: :x86_64     |
      | test do                      |
    And kogen-homebrew-tap-20261106: the file "Formula/kogen.rb" contains "node-path"
    And kogen-homebrew-tap-20261106: the file "Formula/kogen.rb" contains "kogen version"

  Scenario: update-formula.sh documents the kogen/release-archive contract on its first line
    Then kogen-homebrew-tap-20261106: the first line of "scripts/update-formula.sh" starts with "#" and contains:
      | kogen/release-archive                                                                           |
      | https://github.com/KogenAI/kogen/releases/download/<version>/kogen-<version>-<os>-<arch>.tar.gz |
      | SHA256SUMS                                                                                      |

  Scenario: update-formula.sh rewrites only the url, sha256 and version lines, release after release
    Given kogen-homebrew-tap-20261106: a temporary copy of "Formula/kogen.rb" and "scripts/update-formula.sh"
    When kogen-homebrew-tap-20261106: I run update-formula.sh in the copy with "v0.2.0-dev.0123abcd" "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210"
    Then kogen-homebrew-tap-20261106: update-formula.sh exited with status 0
    And kogen-homebrew-tap-20261106: the copied formula equals the formula before that run with these replacements:
      | from                                                                                                                 | to                                                                                                                   |
      | https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-darwin-arm64.tar.gz | https://github.com/KogenAI/kogen/releases/download/v0.2.0-dev.0123abcd/kogen-v0.2.0-dev.0123abcd-darwin-arm64.tar.gz |
      | https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz | https://github.com/KogenAI/kogen/releases/download/v0.2.0-dev.0123abcd/kogen-v0.2.0-dev.0123abcd-linux-x86_64.tar.gz |
      | 2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c                                                     | 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef                                                     |
      | 3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0                                                     | fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210                                                     |
      | version "0.1.0-dev.47236bbb"                                                                                         | version "0.2.0-dev.0123abcd"                                                                                         |
    When kogen-homebrew-tap-20261106: I run update-formula.sh in the copy with "v0.3.0" "1111111111111111111111111111111111111111111111111111111111111111" "2222222222222222222222222222222222222222222222222222222222222222"
    Then kogen-homebrew-tap-20261106: update-formula.sh exited with status 0
    And kogen-homebrew-tap-20261106: the copied formula equals the formula before that run with these replacements:
      | from                                                                                                                 | to                                                                                             |
      | https://github.com/KogenAI/kogen/releases/download/v0.2.0-dev.0123abcd/kogen-v0.2.0-dev.0123abcd-darwin-arm64.tar.gz | https://github.com/KogenAI/kogen/releases/download/v0.3.0/kogen-v0.3.0-darwin-arm64.tar.gz     |
      | https://github.com/KogenAI/kogen/releases/download/v0.2.0-dev.0123abcd/kogen-v0.2.0-dev.0123abcd-linux-x86_64.tar.gz | https://github.com/KogenAI/kogen/releases/download/v0.3.0/kogen-v0.3.0-linux-x86_64.tar.gz     |
      | 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef                                                     | 1111111111111111111111111111111111111111111111111111111111111111                               |
      | fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210                                                     | 2222222222222222222222222222222222222222222222222222222222222222                               |
      | version "0.2.0-dev.0123abcd"                                                                                         | version "0.3.0"                                                                                |

  Scenario: brew-check.sh checks a committed copy of the working tree after trusting it, then cleans up so a second run also passes
    Given kogen-homebrew-tap-20261106: a committed sandbox copy of the repository with an uncommitted line added to "Formula/kogen.rb"
    And kogen-homebrew-tap-20261106: a fake Homebrew on PATH with these formulae already installed:
      | zlib |
    When kogen-homebrew-tap-20261106: I run brew-check.sh in the sandbox
    Then kogen-homebrew-tap-20261106: brew-check.sh exited with status 0
    And kogen-homebrew-tap-20261106: the last line of the brew-check output is "brew-check: passed"
    And kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | trust --tap kogenai/tap          |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | install kogenai/tap/kogen        |
      | test kogenai/tap/kogen           |
      | untrust --tap kogenai/tap        |
      | untap kogenai/tap                |
    And kogen-homebrew-tap-20261106: the formula the fake Homebrew tapped is the sandbox working-tree formula with the uncommitted line
    And kogen-homebrew-tap-20261106: the temporary copy no longer exists
    And kogen-homebrew-tap-20261106: the fake Homebrew has no tap and no trusted tap
    And kogen-homebrew-tap-20261106: the fake Homebrew installed formulae are exactly:
      | zlib |
    When kogen-homebrew-tap-20261106: I run brew-check.sh in the sandbox
    Then kogen-homebrew-tap-20261106: brew-check.sh exited with status 0
    And kogen-homebrew-tap-20261106: the last line of the brew-check output is "brew-check: passed"
    And kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | trust --tap kogenai/tap          |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | install kogenai/tap/kogen        |
      | test kogenai/tap/kogen           |
      | untrust --tap kogenai/tap        |
      | untap kogenai/tap                |
    And kogen-homebrew-tap-20261106: the temporary copy no longer exists
    And kogen-homebrew-tap-20261106: the fake Homebrew has no tap and no trusted tap
    And kogen-homebrew-tap-20261106: the fake Homebrew installed formulae are exactly:
      | zlib |

  Scenario: brew-check.sh reports a failing audit first, skips install and test, and still cleans up
    Given kogen-homebrew-tap-20261106: a committed sandbox copy of the repository with an uncommitted line added to "Formula/kogen.rb"
    And kogen-homebrew-tap-20261106: a fake Homebrew on PATH with these formulae already installed:
      | zlib |
    And kogen-homebrew-tap-20261106: the fake Homebrew fails "audit" with this output:
      """
      kogenai/tap/kogen
        * fake audit problem
      """
    When kogen-homebrew-tap-20261106: I run brew-check.sh in the sandbox
    Then kogen-homebrew-tap-20261106: brew-check.sh exited with a non-zero status
    And kogen-homebrew-tap-20261106: the first line of the brew-check output is "brew-check: failed at audit"
    And kogen-homebrew-tap-20261106: the brew-check output contains "* fake audit problem"
    And kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | trust --tap kogenai/tap          |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | untrust --tap kogenai/tap        |
      | untap kogenai/tap                |
    And kogen-homebrew-tap-20261106: the temporary copy no longer exists
    And kogen-homebrew-tap-20261106: the fake Homebrew has no tap and no trusted tap
    And kogen-homebrew-tap-20261106: the fake Homebrew installed formulae are exactly:
      | zlib |

  Scenario: brew-check.sh reports a failing brew test first and uninstalls only what the run installed
    Given kogen-homebrew-tap-20261106: a committed sandbox copy of the repository with an uncommitted line added to "Formula/kogen.rb"
    And kogen-homebrew-tap-20261106: a fake Homebrew on PATH with these formulae already installed:
      | node |
      | zlib |
    And kogen-homebrew-tap-20261106: the fake Homebrew fails "test" with this output:
      """
      Error: kogenai/tap/kogen: failed
      fake test failure
      """
    When kogen-homebrew-tap-20261106: I run brew-check.sh in the sandbox
    Then kogen-homebrew-tap-20261106: brew-check.sh exited with a non-zero status
    And kogen-homebrew-tap-20261106: the first line of the brew-check output is "brew-check: failed at test"
    And kogen-homebrew-tap-20261106: the brew-check output contains "fake test failure"
    And kogen-homebrew-tap-20261106: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | trust --tap kogenai/tap          |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | install kogenai/tap/kogen        |
      | test kogenai/tap/kogen           |
      | untrust --tap kogenai/tap        |
      | untap kogenai/tap                |
    And kogen-homebrew-tap-20261106: the temporary copy no longer exists
    And kogen-homebrew-tap-20261106: the fake Homebrew has no tap and no trusted tap
    And kogen-homebrew-tap-20261106: the fake Homebrew installed formulae are exactly:
      | node |
      | zlib |

  Scenario: NOTICE carries kogen.dev's notice wording
    Then kogen-homebrew-tap-20261106: the file "NOTICE" is exactly:
      """
      Kogen
      Copyright 2026 Optimum Tech, LLC

      Licensed under the Apache License, Version 2.0.
      """

  Scenario: README gives the one install command, what it installs and how a release updates the formula
    Then kogen-homebrew-tap-20261106: the file "README.md" has exactly one line containing "brew install", and that line contains "brew install kogenai/tap/kogen"
    And kogen-homebrew-tap-20261106: the file "README.md" contains "v0.1.0-dev.47236bbb"
    And kogen-homebrew-tap-20261106: the file "README.md" contains "macOS arm64"
    And kogen-homebrew-tap-20261106: the file "README.md" contains "Linux x86-64"
    And kogen-homebrew-tap-20261106: the file "README.md" contains "scripts/update-formula.sh"
    And kogen-homebrew-tap-20261106: the file "README.md" contains "SHA256SUMS"

  Scenario: The tap adds only the formula, its two scripts and NOTICE
    Then kogen-homebrew-tap-20261106: the repository files outside .git, .kogen and features are exactly:
      | .gitignore                |
      | Formula/kogen.rb          |
      | LICENSE                   |
      | NOTICE                    |
      | README.md                 |
      | scripts/brew-check.sh     |
      | scripts/update-formula.sh |
