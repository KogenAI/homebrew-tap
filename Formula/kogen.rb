class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.62015185/kogen-v0.1.0-dev.62015185-linux-x86_64.tar.gz"
  version "0.1.0-dev.62015185"
  sha256 "0473534fc05dd60acac1c49afae2f3ff901d6035cfef3d3fbb345d8e0a6068d7"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.62015185/kogen-v0.1.0-dev.62015185-darwin-arm64.tar.gz"
      sha256 "01d1a9ce6f88b21f513bd35cba18d1934651d7293fe5165d0cdf6b517c8430a5"
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
