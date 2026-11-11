class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.bf7bc099/kogen-v0.1.0-dev.bf7bc099-linux-x86_64.tar.gz"
  version "0.1.0-dev.bf7bc099"
  sha256 "534dfbfe9e9362a25d78fad7c87082089a13ffffe9828b63d17f33b9e52422d0"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.bf7bc099/kogen-v0.1.0-dev.bf7bc099-darwin-arm64.tar.gz"
      sha256 "213017336475d777f255ac128ed2060d4674333bdf82b3720235980b70b37e62"
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
