class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f923544e/kogen-v0.1.0-dev.f923544e-linux-x86_64.tar.gz"
  version "0.1.0-dev.f923544e"
  sha256 "0a75abc46dc295ac92dfca87b85e4f75df9ff5e710555e37999d2b4745cb66b8"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.f923544e/kogen-v0.1.0-dev.f923544e-darwin-arm64.tar.gz"
      sha256 "aa17bed587380453ac088c889d8111d1c3e407b1bd87bd6adaac765a8d09497c"
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
