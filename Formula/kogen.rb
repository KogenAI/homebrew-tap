class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.040bd707/kogen-v0.1.0-dev.040bd707-linux-x86_64.tar.gz"
  version "0.1.0-dev.040bd707"
  sha256 "b9a3100fadcaddc541acbef347eacbe4064382860dbb0c1193de9316d580df58"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.040bd707/kogen-v0.1.0-dev.040bd707-darwin-arm64.tar.gz"
      sha256 "24733d5df0ecde0753f73c4bbaf1f8dc588b4a1218cb8aec3d087e885672170e"
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
