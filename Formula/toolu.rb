class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.13.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.13.1/toolu-darwin-arm64.tar.gz"
      sha256 "b7bbdb21296f5aab90fa76d9adf4756429de533318f4c9293b5e6ef3628d3c7f"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.13.1/toolu-darwin-amd64.tar.gz"
      sha256 "3dbc9084d05865bf33d753d3d4aca447770ee077bf3296bb622c9f532623b1a0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.13.1/toolu-linux-arm64.tar.gz"
      sha256 "b163bca8c90b6892f625d79b695efec4dc29f5669656b90c6ff61034ebc20e03"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.13.1/toolu-linux-amd64.tar.gz"
      sha256 "a97709ab2a3ad60def952c044852506107f968885f1c25a87d6db1e93e30f7e3"
    end
  end

  def install
    bin.install "toolu"
    generate_completions_from_executable(bin/"toolu", "completions")
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
