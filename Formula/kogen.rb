class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.3c70abcb/kogen-v0.1.0-dev.3c70abcb-linux-x86_64.tar.gz"
  version "0.1.0-dev.3c70abcb"
  sha256 "7e89878df8ac027721dceffe384768127c635e5257f16da0425a0dbf1640b029"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.3c70abcb/kogen-v0.1.0-dev.3c70abcb-darwin-arm64.tar.gz"
      sha256 "d6272c5417ecb074925c7cf916bfb15e3f9232c0a52b874a11948a3f46e7cc80"
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
