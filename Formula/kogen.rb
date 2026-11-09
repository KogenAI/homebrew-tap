class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.cd805d8f/kogen-v0.1.0-dev.cd805d8f-linux-x86_64.tar.gz"
  version "0.1.0-dev.cd805d8f"
  sha256 "f5b98e92c84cb003e9fc41d4ab4fa0b2b8a2787ddc44df7cd3a403123d9c8cbe"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.cd805d8f/kogen-v0.1.0-dev.cd805d8f-darwin-arm64.tar.gz"
      sha256 "98a4b023d510f7b3301fd8d46d16d8919f349d39793265ceaa3c9443803d7ea8"
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
