class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.2e6a8976/kogen-v0.1.0-dev.2e6a8976-linux-x86_64.tar.gz"
  version "0.1.0-dev.2e6a8976"
  sha256 "05713cbb33648d4fd175dcbc7c14abb1d94454b3d5edc1a33abca7afd400c49e"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.2e6a8976/kogen-v0.1.0-dev.2e6a8976-darwin-arm64.tar.gz"
      sha256 "0cf49899ef9743889f2720b78fa4a31bda138c3546bc8ca2ec310a4ff8a00d5f"
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
