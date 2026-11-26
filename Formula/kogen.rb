class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7705803f/kogen-v0.1.0-dev.7705803f-linux-x86_64.tar.gz"
  version "0.1.0-dev.7705803f"
  sha256 "b2810a8366400520521929d1a001b8454d767a80d244d39b8da05abd46bcca89"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7705803f/kogen-v0.1.0-dev.7705803f-darwin-arm64.tar.gz"
      sha256 "eaf90c3595ccc91b9c255f5e83b5e9a64d2d7bf4ff0714132be682dff38c4079"
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
