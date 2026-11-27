class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.fb791b24/kogen-v0.1.0-dev.fb791b24-linux-x86_64.tar.gz"
  version "0.1.0-dev.fb791b24"
  sha256 "ad0bf0cd9fd5831f1733cf44bf3eaf26b8016c1fdfb184fdc9691ec7a35b27e7"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.fb791b24/kogen-v0.1.0-dev.fb791b24-darwin-arm64.tar.gz"
      sha256 "67f41c0d17cb1326147bf61d31ad60687800cc3d9ac4b22b11217ebfdf778383"
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
