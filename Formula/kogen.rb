class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.30cf6619/kogen-v0.1.0-dev.30cf6619-linux-x86_64.tar.gz"
  version "0.1.0-dev.30cf6619"
  sha256 "ee7a2d6dcfbf58a13099777fc63b17bcdc4fea809b29d581509acb0d777787bb"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.30cf6619/kogen-v0.1.0-dev.30cf6619-darwin-arm64.tar.gz"
      sha256 "b4983994a1d9ee476f3bdcf70b50252422d7e6bb69247fcbc143c8a61e50bda5"
    end
  end

  on_linux do
    depends_on arch: :x86_64
  end

  def install
    (lib/"kogen").install "bin", "docs", "lib", "licenses", "README.md", "LICENSE", "NOTICE"
    (lib/"kogen/node-path").write "#{formula_opt_bin("node")}/node\n"
    bin.install_symlink lib/"kogen/bin/kogen"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/kogen version")
  end
end
