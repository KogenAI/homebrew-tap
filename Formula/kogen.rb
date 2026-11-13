class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.c68b106a/kogen-v0.1.0-dev.c68b106a-linux-x86_64.tar.gz"
  version "0.1.0-dev.c68b106a"
  sha256 "f43950d9d6a2cf56cb4451375acd0863e2f0b9258c73fdb11cf2658deaefd02d"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.c68b106a/kogen-v0.1.0-dev.c68b106a-darwin-arm64.tar.gz"
      sha256 "a3c3a934c1ea1ba03943a9de4125f988d31e23c1449c5ba272836029c764c6a5"
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
