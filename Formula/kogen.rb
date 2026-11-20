class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.fc6e28d3/kogen-v0.1.0-dev.fc6e28d3-linux-x86_64.tar.gz"
  version "0.1.0-dev.fc6e28d3"
  sha256 "cce75c8c60e4ba7b933d2e5191d94d520257b828f33ee57613f21fa4e7691f39"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.fc6e28d3/kogen-v0.1.0-dev.fc6e28d3-darwin-arm64.tar.gz"
      sha256 "6a5e8139ca08a1f1ae48d8a6e58fb3a77bc702a15fe4b55a5991908f89a4d74e"
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
