class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7f8cf638/kogen-v0.1.0-dev.7f8cf638-linux-x86_64.tar.gz"
  version "0.1.0-dev.7f8cf638"
  sha256 "71734b9494f1ed6511001b18d2385743903a5979f4b491e2350e76576c3319aa"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.7f8cf638/kogen-v0.1.0-dev.7f8cf638-darwin-arm64.tar.gz"
      sha256 "70fbc44996a009d2c87348f38481f68beaed0c9fc2d3e993190820ca71f6e780"
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
