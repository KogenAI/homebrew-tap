class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4fb52c19/kogen-v0.1.0-dev.4fb52c19-linux-x86_64.tar.gz"
  version "0.1.0-dev.4fb52c19"
  sha256 "1e804612245431de8a1a4fbe5b1f262124ac03523b74f6f5b50b99918b62373d"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4fb52c19/kogen-v0.1.0-dev.4fb52c19-darwin-arm64.tar.gz"
      sha256 "cbe915b39c4ba8c591fa93b7c71049a8ccf001b4a03d0be0cf5c3c26e8bbfd93"
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
