class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.45a99041/kogen-v0.1.0-dev.45a99041-linux-x86_64.tar.gz"
  version "0.1.0-dev.45a99041"
  sha256 "6dd940db98f4278433c35b6c1eb5ec78f525ca994a0f6df44d83b5dc582895d0"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.45a99041/kogen-v0.1.0-dev.45a99041-darwin-arm64.tar.gz"
      sha256 "a4f210a3603c2e165f1e1f6ac2b167271adbc4bbb9659d24f0f98345742b1bbd"
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
