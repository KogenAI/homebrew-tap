class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.6203c68f/kogen-v0.1.0-dev.6203c68f-linux-x86_64.tar.gz"
  version "0.1.0-dev.6203c68f"
  sha256 "01dc1d7dac0df741466bf5fcfe874acce49d48488268bc4745a1a2b7352e0514"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.6203c68f/kogen-v0.1.0-dev.6203c68f-darwin-arm64.tar.gz"
      sha256 "adc55bc9fcfbec7c4d03ed9709b507bd206c22a3ba8fc0aa186f10523a9460a4"
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
