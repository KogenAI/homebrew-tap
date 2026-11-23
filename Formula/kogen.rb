class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.0e72094b/kogen-v0.1.0-dev.0e72094b-linux-x86_64.tar.gz"
  version "0.1.0-dev.0e72094b"
  sha256 "30229860c6224b5bccc334ecfd242c4ac51343bf481040fa01f51f3a2eceaeb2"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.0e72094b/kogen-v0.1.0-dev.0e72094b-darwin-arm64.tar.gz"
      sha256 "d8010551466420c02e74bb8c8379c136494c41737dfebfbfc131d19b6a386fd1"
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
