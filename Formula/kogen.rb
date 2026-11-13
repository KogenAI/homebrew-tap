class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.13a970c0/kogen-v0.1.0-dev.13a970c0-linux-x86_64.tar.gz"
  version "0.1.0-dev.13a970c0"
  sha256 "3cf3f392462c5a02bbe5b158ae4204c14e032e95cb02e187252c456ba46c7bf1"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.13a970c0/kogen-v0.1.0-dev.13a970c0-darwin-arm64.tar.gz"
      sha256 "fa6578ca05cbece536e4f4ec08aa17b7482bfb0b80b90647cf9dfa57d4e7873d"
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
