class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f4c7170a/kogen-v0.1.0-dev.f4c7170a-linux-x86_64.tar.gz"
  version "0.1.0-dev.f4c7170a"
  sha256 "5b44d030e46b9072957adf7798251ec9c2c7a3e3fed04ce41e61528788c0840a"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f4c7170a/kogen-v0.1.0-dev.f4c7170a-darwin-arm64.tar.gz"
      sha256 "3c58f1b21f8aa49b0fc4aef6316643de05b1191037065919def7ddc229decfa0"
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
