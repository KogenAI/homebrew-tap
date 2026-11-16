class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.bbf56fdc/kogen-v0.1.0-dev.bbf56fdc-linux-x86_64.tar.gz"
  version "0.1.0-dev.bbf56fdc"
  sha256 "06fc4431611253c8d8916dda62c333c656d66272d1c2cb598e343e442bc8437e"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.bbf56fdc/kogen-v0.1.0-dev.bbf56fdc-darwin-arm64.tar.gz"
      sha256 "877ebe0f7842321eeaac73130fddb93bde145469359428cbc0d4dedbdcc96b8d"
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
