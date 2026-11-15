class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.891c91b3/kogen-v0.1.0-dev.891c91b3-linux-x86_64.tar.gz"
  version "0.1.0-dev.891c91b3"
  sha256 "8d93ab23cb1f686fd808780858ea765c5b64f98b2c9a40cce41d74be1f14b393"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.891c91b3/kogen-v0.1.0-dev.891c91b3-darwin-arm64.tar.gz"
      sha256 "af3c86371630cbfa3fa8d52f67bbe38263421058a5404674ea719cf7ec467a4f"
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
