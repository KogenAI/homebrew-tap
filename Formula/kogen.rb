class Kogen < Formula
  desc "Takes one requested feature through shaping, building, verifying and committing"
  homepage "https://kogen.dev"
  url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4afdee16/kogen-v0.1.0-dev.4afdee16-linux-x86_64.tar.gz"
  version "0.1.0-dev.4afdee16"
  sha256 "c2754ec57c322b7303d1658947f32dd14066745cc581b5fbb3e11c4d77b24674"
  license "Apache-2.0"

  depends_on "node"

  on_macos do
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/KogenAI/kogen/releases/download/v0.1.0-dev.4afdee16/kogen-v0.1.0-dev.4afdee16-darwin-arm64.tar.gz"
      sha256 "a23056c32f7f7217574a6e51c423233155fda751c9c5aadcf44718db16698062"
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
