class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4c7491f2/kogen-v0.1.0-dev.4c7491f2-linux-x86_64.tar.gz"
  version "0.1.0-dev.4c7491f2"
  sha256 "fa3b4c2035307657709ab2cde7f2193e39649369935b934c8ff78a95aa849aae"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4c7491f2/kogen-v0.1.0-dev.4c7491f2-darwin-arm64.tar.gz"
      sha256 "712116fc4bcd76d18cc695cc335ad78ece041830d7743e0746f222925428ce0c"
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
