class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.a2cb3294/kogen-v0.1.0-dev.a2cb3294-linux-x86_64.tar.gz"
  version "0.1.0-dev.a2cb3294"
  sha256 "29cfdc4e39961d4d6cefc7b57d39607a26f227da22e2ba747715fe4b80196ce2"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.a2cb3294/kogen-v0.1.0-dev.a2cb3294-darwin-arm64.tar.gz"
      sha256 "15292dc40d4216e5c2e5b5083d10de218c2cd2fd71ad8c0452099739c29e10fc"
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
