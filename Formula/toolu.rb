class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.0/toolu-darwin-arm64.tar.gz"
      sha256 "b556ff1f78bdcd08bd5ac8a77ce94fb31c62a69f0d077525a8c8b7241eff1d16"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.0/toolu-darwin-amd64.tar.gz"
      sha256 "2b043d38960de92c9394bd8b6db39f547dabb5a92fd1f546128e12ed638c56da"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.0/toolu-linux-arm64.tar.gz"
      sha256 "df89f0648e6a99979f863c4e9122f945ed36b562de8f19fbd5d7830e3b63947a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.4.0/toolu-linux-amd64.tar.gz"
      sha256 "24063fe7a9e7535ff4cd1205e71d783c5205c198047ff1cec5153def355d1e9c"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
