class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.be8c2c69/kogen-v0.1.0-dev.be8c2c69-linux-x86_64.tar.gz"
  version "0.1.0-dev.be8c2c69"
  sha256 "8998bacd013ebc7e23f436e6eec207d61946c9e717bfa70cc46630fbcfaea4d7"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.be8c2c69/kogen-v0.1.0-dev.be8c2c69-darwin-arm64.tar.gz"
      sha256 "9a05f37457839c32a23c37ae75e0b1e01578186fa483c40a89e9a36609a94f1d"
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
