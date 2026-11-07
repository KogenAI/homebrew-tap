Feature: The tap README and brew-check.sh use brew trust first

  Scenario: brew-check.sh runs the user's install sequence on the tapped copy and cleans up
    Given tap-readme-and-check-use-brew-trust: a sandbox repository with a committed formula file
    And tap-readme-and-check-use-brew-trust: a fake Homebrew on PATH that has the trust subcommand, refuses to audit, install or test a formula from an untrusted tap, and has wget installed
    When tap-readme-and-check-use-brew-trust: I run brew-check.sh in the sandbox
    Then tap-readme-and-check-use-brew-trust: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | trust kogenai/tap                |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | install kogenai/tap/kogen        |
      | test kogenai/tap/kogen           |
      | untrust kogenai/tap              |
      | untap kogenai/tap                |
    And tap-readme-and-check-use-brew-trust: brew-check.sh exited with status 0
    And tap-readme-and-check-use-brew-trust: the last line of the brew-check output is "brew-check: passed"
    And tap-readme-and-check-use-brew-trust: the fake Homebrew has no tap and no trusted tap and only wget installed

  Scenario: brew-check.sh passes only because it trusts the tap before installing
    Given tap-readme-and-check-use-brew-trust: a sandbox repository with a committed formula file
    And tap-readme-and-check-use-brew-trust: a fake Homebrew on PATH that has the trust subcommand, refuses to audit, install or test a formula from an untrusted tap, and has wget installed
    When tap-readme-and-check-use-brew-trust: I run brew-check.sh in the sandbox
    Then tap-readme-and-check-use-brew-trust: brew-check.sh exited with status 0
    And tap-readme-and-check-use-brew-trust: the brew-check output does not contain "Refusing to load formula"
    And tap-readme-and-check-use-brew-trust: the fake Homebrew completed the install and the test of the formula

  Scenario: brew-check.sh skips the trust step on a Homebrew without brew trust
    Given tap-readme-and-check-use-brew-trust: a sandbox repository with a committed formula file
    And tap-readme-and-check-use-brew-trust: a fake Homebrew on PATH that has no trust subcommand and has wget installed
    When tap-readme-and-check-use-brew-trust: I run brew-check.sh in the sandbox
    Then tap-readme-and-check-use-brew-trust: the fake Homebrew received exactly these commands, in order:
      | tap kogenai/tap <temporary copy> |
      | style kogenai/tap/kogen          |
      | audit --strict kogenai/tap/kogen |
      | install kogenai/tap/kogen        |
      | test kogenai/tap/kogen           |
      | untap kogenai/tap                |
    And tap-readme-and-check-use-brew-trust: brew-check.sh exited with status 0
    And tap-readme-and-check-use-brew-trust: the last line of the brew-check output is "brew-check: passed"
    And tap-readme-and-check-use-brew-trust: the fake Homebrew has no tap and no trusted tap and only wget installed

  Scenario: README.md shows the two-command install on one line and says why
    Then tap-readme-and-check-use-brew-trust: the file "README.md" has exactly one line containing "brew install kogenai/tap/kogen", and that line is exactly "brew trust kogenai/tap && brew install kogenai/tap/kogen"
    And tap-readme-and-check-use-brew-trust: the file "README.md" contains "Homebrew 7"
    And tap-readme-and-check-use-brew-trust: the file "README.md" contains "trusted"

  Scenario: README.md names no release version
    Then tap-readme-and-check-use-brew-trust: the file "README.md" does not contain "v0.1.0-dev"
    And tap-readme-and-check-use-brew-trust: the file "README.md" does not contain "0.1.0-dev"
    And tap-readme-and-check-use-brew-trust: the file "README.md" names no release version

  Scenario: README.md is short and says how to update
    Then tap-readme-and-check-use-brew-trust: the file "README.md" has at most 25 lines
    And tap-readme-and-check-use-brew-trust: the file "README.md" contains "brew upgrade kogen"
    And tap-readme-and-check-use-brew-trust: the file "README.md" contains "scripts/update-formula.sh"
