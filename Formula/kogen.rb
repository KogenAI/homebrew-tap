class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.ac25b285/kogen-v0.1.0-dev.ac25b285-linux-x86_64.tar.gz"
  version "0.1.0-dev.ac25b285"
  sha256 "e849ab433e64272ce62ddffdfe61ae94cbfc65be88248c3faacf566fdcfa0431"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.ac25b285/kogen-v0.1.0-dev.ac25b285-darwin-arm64.tar.gz"
      sha256 "2f40c036107bce0f4eeb4df0605bea22ed33c327e3e5e68c5462b214c50455c3"
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
