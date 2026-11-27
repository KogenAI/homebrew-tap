class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7f4a103d/kogen-v0.1.0-dev.7f4a103d-linux-x86_64.tar.gz"
  version "0.1.0-dev.7f4a103d"
  sha256 "5f5df9ba1e27de6f8deff2e13e251adcd2661690b7361842b1388323cc467720"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7f4a103d/kogen-v0.1.0-dev.7f4a103d-darwin-arm64.tar.gz"
      sha256 "0a97706a7e6bbeb41b2508dd5c741180aedbc3f310fad313ad520df948971f6d"
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
