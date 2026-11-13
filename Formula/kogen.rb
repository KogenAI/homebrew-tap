class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.6bf446d6/kogen-v0.1.0-dev.6bf446d6-linux-x86_64.tar.gz"
  version "0.1.0-dev.6bf446d6"
  sha256 "d1ea22acbb1125d741709ea48bdacb469faa7a65289fb81ad997213ac5c245be"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.6bf446d6/kogen-v0.1.0-dev.6bf446d6-darwin-arm64.tar.gz"
      sha256 "642647f89f14e25b21ccb44a4c10cafc3994e2cf7d7eee9cdfd28a3f28721e64"
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
