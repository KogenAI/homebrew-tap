class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.99a57890/kogen-v0.1.0-dev.99a57890-linux-x86_64.tar.gz"
  version "0.1.0-dev.99a57890"
  sha256 "eab30522fe48b4b2417215de1c56bd473d9e2bf858a6616d3ff0de1424bafeb8"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.99a57890/kogen-v0.1.0-dev.99a57890-darwin-arm64.tar.gz"
      sha256 "e827227cc72664cbaa2073ec728351f1dad84f4e31c396d56561f5078426c935"
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
