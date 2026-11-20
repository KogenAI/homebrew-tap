class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.611aa40f/kogen-v0.1.0-dev.611aa40f-linux-x86_64.tar.gz"
  version "0.1.0-dev.611aa40f"
  sha256 "7223c6fde202867a04f8f1ef6b19f480c9c987ece31a49a7df8bf54c4546f26b"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.611aa40f/kogen-v0.1.0-dev.611aa40f-darwin-arm64.tar.gz"
      sha256 "5d5064e8d2cfc452f6aa74a6c9bb1c7bb78181d08ef069d9411b1faf38e5849c"
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
