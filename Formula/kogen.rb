class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f716582a/kogen-v0.1.0-dev.f716582a-linux-x86_64.tar.gz"
  version "0.1.0-dev.f716582a"
  sha256 "2b751ec66ae01136dc3b7582408bd58318bfb6a9ade810244e16d3e5fd6aecee"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f716582a/kogen-v0.1.0-dev.f716582a-darwin-arm64.tar.gz"
      sha256 "55ad76ef99f61a8b03c511f93c706df5b6a4e30ef3f237399a234a1f61bde872"
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
