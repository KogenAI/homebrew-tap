class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.c7eaef99/kogen-v0.1.0-dev.c7eaef99-linux-x86_64.tar.gz"
  version "0.1.0-dev.c7eaef99"
  sha256 "ed8b989d8c04c90b847a39275644a5badf4b4290d2f2ec9df576e9ed3928bedd"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.c7eaef99/kogen-v0.1.0-dev.c7eaef99-darwin-arm64.tar.gz"
      sha256 "b8d57bc368940de2e1fca1a110e4b7fbe59b8018866baa3e284cd4de47a77817"
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
