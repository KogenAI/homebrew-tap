class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.eed14b37/kogen-v0.1.0-dev.eed14b37-linux-x86_64.tar.gz"
  version "0.1.0-dev.eed14b37"
  sha256 "4ae6f1343703003e21cd0ce70c0f5afc240c9935a3443d9467724c6b41e2b962"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.eed14b37/kogen-v0.1.0-dev.eed14b37-darwin-arm64.tar.gz"
      sha256 "a67b203611d869a58ec6203ca657992944fb3f95c5431c7879d7764e4f343aa2"
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
