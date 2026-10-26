class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.4.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.1/toolu-darwin-arm64.tar.gz"
      sha256 "25134e7a5046cd2af0d60a3ed0648b03d8bdf05d05e8ef7c42960e336ec4241a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.1/toolu-darwin-amd64.tar.gz"
      sha256 "687907523cbcd5b912dc4f3d3ec5bfda8feea1754dfc5d4e51c0821ccc4c1880"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.1/toolu-linux-arm64.tar.gz"
      sha256 "6c577af5efe7cb37b9eb9f8b46b177109c8b2bd68ced650de0191967a997117d"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.1/toolu-linux-amd64.tar.gz"
      sha256 "7a636e5053f17e337c267ffa9520ffa879426bdb40edfbfce21c9fc6786f6dcd"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
