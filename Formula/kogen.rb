class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.3f2ff9b0/kogen-v0.1.0-dev.3f2ff9b0-linux-x86_64.tar.gz"
  version "0.1.0-dev.3f2ff9b0"
  sha256 "fda9d0dd61dd9038eac7d40951eede6fbdb957e4a2bb1e4ff27fa4ee81ac6e48"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.3f2ff9b0/kogen-v0.1.0-dev.3f2ff9b0-darwin-arm64.tar.gz"
      sha256 "2bb0d3e0f0a246192738a999811e2ee533d98fc3b20154db7aa65f8dd992830c"
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
