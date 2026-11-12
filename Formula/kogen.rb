class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f328a1bf/kogen-v0.1.0-dev.f328a1bf-linux-x86_64.tar.gz"
  version "0.1.0-dev.f328a1bf"
  sha256 "a560fc8a9870e7ce39e7be859e43736580552fb45201baabf7f0f92bb496f3bf"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f328a1bf/kogen-v0.1.0-dev.f328a1bf-darwin-arm64.tar.gz"
      sha256 "ef4d44fcff245d932f20b3634156749935692df3e2d2ba33d8535cac1656dda6"
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
