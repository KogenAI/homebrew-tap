class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.be815d54/kogen-v0.1.0-dev.be815d54-linux-x86_64.tar.gz"
  version "0.1.0-dev.be815d54"
  sha256 "59b09648c869e083b65f934de5fa64d79f3926500f8ed1cbc478f0f3f6d2aecf"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.be815d54/kogen-v0.1.0-dev.be815d54-darwin-arm64.tar.gz"
      sha256 "540a9e361a6e98e5c80c42a1accae3f360798fdea38a6e2b1ae5d70f33daa7bb"
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
