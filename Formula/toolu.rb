class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.1.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.2/toolu-darwin-arm64.tar.gz"
      sha256 "ebe41f1490c174f099733b89416c53f7de93df29035870a79388b88881949a88"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.2/toolu-darwin-amd64.tar.gz"
      sha256 "091fee4f91e622756f22590ce241c3e14702b3332d0f267000a65c0522fb90ea"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.2/toolu-linux-arm64.tar.gz"
      sha256 "e0af6130564ac576db7f6913f15153c418877f7bc689a40169618229c97cf2f7"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.2/toolu-linux-amd64.tar.gz"
      sha256 "7f4d325432a0af9af1c40b19367ce85e5685a5c0c062d3a4559b8a3b44399f73"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
