class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.b5eb6aa2/kogen-v0.1.0-dev.b5eb6aa2-linux-x86_64.tar.gz"
  version "0.1.0-dev.b5eb6aa2"
  sha256 "b37b88e73ce1c7ee8cf50d1536d674e569313e99819b0c1a7bb960902b6a12af"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.b5eb6aa2/kogen-v0.1.0-dev.b5eb6aa2-darwin-arm64.tar.gz"
      sha256 "7744663a3ba1c2d531b282ea8426031e0e8257bdd94a8cc80daec136b7f14f11"
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
