class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.5b280faf/kogen-v0.1.0-dev.5b280faf-linux-x86_64.tar.gz"
  version "0.1.0-dev.5b280faf"
  sha256 "ce914aff0d5101c5a3ccb1827f321e83eef1660581b727428e3856153edffddc"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.5b280faf/kogen-v0.1.0-dev.5b280faf-darwin-arm64.tar.gz"
      sha256 "c2a58e45d173c4458fb9c0fc9b66b403d9dfc4917a41dc34cbc17db4bfa604a2"
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
