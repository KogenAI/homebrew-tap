class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.d9bab907/kogen-v0.1.0-dev.d9bab907-linux-x86_64.tar.gz"
  version "0.1.0-dev.d9bab907"
  sha256 "fb49b73b09b51bf814f440a967d9fc2308f021616dfcfcaab3ee99d39a876d88"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.d9bab907/kogen-v0.1.0-dev.d9bab907-darwin-arm64.tar.gz"
      sha256 "8a474b3f3d5dde2f68d8e21af0d4b1b91e89dc9e25479a93fdb831fe4a9e17e6"
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
