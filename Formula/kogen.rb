class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.22012a26/kogen-v0.1.0-dev.22012a26-linux-x86_64.tar.gz"
  version "0.1.0-dev.22012a26"
  sha256 "795b7e76e8fe5631a791f20e36145c6f30bac785bfe5e9e40f784c2122020873"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.22012a26/kogen-v0.1.0-dev.22012a26-darwin-arm64.tar.gz"
      sha256 "c3375127a4f182f045036c929b0f732844126e17716a5d0e621abaefb644b341"
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
