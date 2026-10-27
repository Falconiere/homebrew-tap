class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.5.0/toolu-darwin-arm64.tar.gz"
      sha256 "2cd20c369c379b223bbbb0eeb02d1e4873d6fca3bcb7c9fe2c7ce1529479b54e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.5.0/toolu-darwin-amd64.tar.gz"
      sha256 "dbd427110dfe3bf5e34ee2f72f518d717e6d1c90cb0b01d68113649d8b3ca2ee"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.5.0/toolu-linux-arm64.tar.gz"
      sha256 "c5bb921326bba293ad78ec4eef729010762e9f0cc9b5fccb1e2b8d935e64dacf"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.5.0/toolu-linux-amd64.tar.gz"
      sha256 "5ba049143f62ca99d6c2d104c39362f1880e4aaa999a100d6b7d39431fded09f"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
