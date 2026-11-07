class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-linux-x86_64.tar.gz"
  version "0.1.0-dev.47236bbb"
  sha256 "3646ce55f3088c44581490c5b430348895dbadbc37c9d806380d0d16b3168ce0"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.47236bbb/kogen-v0.1.0-dev.47236bbb-darwin-arm64.tar.gz"
      sha256 "2cc2471e044d0b89bf5abfe7491ff2a0dd7c1039451e0105adc1c2a5a6f6568c"
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
