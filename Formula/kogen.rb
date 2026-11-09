class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.694a0c28/kogen-v0.1.0-dev.694a0c28-linux-x86_64.tar.gz"
  version "0.1.0-dev.694a0c28"
  sha256 "72dfc79e279b6638ee80f9c16801905f14877a9b2089693861d3236526c73f58"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.694a0c28/kogen-v0.1.0-dev.694a0c28-darwin-arm64.tar.gz"
      sha256 "889850feb1d3dc47f59299268369cf25775ff3d3122975ed27dc811f4befb5b6"
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
