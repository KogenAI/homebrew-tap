class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.57140989/kogen-v0.1.0-dev.57140989-linux-x86_64.tar.gz"
  version "0.1.0-dev.57140989"
  sha256 "ec42418c65f9bedd7c755a75f35ae34fe8742c005eafa73c7a2e19a89b62965f"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.57140989/kogen-v0.1.0-dev.57140989-darwin-arm64.tar.gz"
      sha256 "bb0be5db73e519de875985f96e8687f7ac3062eb295d5ee378d1db5b8dd1f61e"
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
