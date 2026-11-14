class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.66f23295/kogen-v0.1.0-dev.66f23295-linux-x86_64.tar.gz"
  version "0.1.0-dev.66f23295"
  sha256 "a18a95b697c151ce6b22922a8075335af40fcd8e399b3557a961ae69a64823f3"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.66f23295/kogen-v0.1.0-dev.66f23295-darwin-arm64.tar.gz"
      sha256 "a8f216e29ed9ba3e2bf12b996c42618a712d9a41ce6e900581debaef09a54c5b"
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
