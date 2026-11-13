class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.499206c0/kogen-v0.1.0-dev.499206c0-linux-x86_64.tar.gz"
  version "0.1.0-dev.499206c0"
  sha256 "93c5ce6a50f31005e5f321710cf2b35c453f113d5c1d06296522f153b515231a"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.499206c0/kogen-v0.1.0-dev.499206c0-darwin-arm64.tar.gz"
      sha256 "3ee737ce1dd75e9937ba4153fed515ae5568dceabfa9a603eeb02d9bbbd12400"
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
