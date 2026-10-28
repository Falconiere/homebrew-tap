class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.6.0/toolu-darwin-arm64.tar.gz"
      sha256 "247118b4f382c6ac573c90d6c1494af12326f1f47a70dce9cb0329166bdf4b82"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.6.0/toolu-darwin-amd64.tar.gz"
      sha256 "c8056de4f1bd8be7f86065ecc29a6943e387b918ef5cd2a742397fe2950a1262"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.6.0/toolu-linux-arm64.tar.gz"
      sha256 "c2f0f3208ec691e451a34ccdcaa3ff56d61e582164032ed7536830a1e62a5a05"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.6.0/toolu-linux-amd64.tar.gz"
      sha256 "00cc4c90b30c2ef36467fffe163d0210306d7c24c79d25e9830d6dca90c734c4"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
