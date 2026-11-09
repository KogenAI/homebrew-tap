class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4cab2b95/kogen-v0.1.0-dev.4cab2b95-linux-x86_64.tar.gz"
  version "0.1.0-dev.4cab2b95"
  sha256 "3593219f74603d068c68f67b19c7d0caf1128e18da83c117314aa2b65dc6127f"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4cab2b95/kogen-v0.1.0-dev.4cab2b95-darwin-arm64.tar.gz"
      sha256 "e7434070b52f09d0a5c10d2e5e72274b5143e3212f028eb5e06b22d27ecfefe5"
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
