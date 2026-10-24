class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.3.0/toolu-darwin-arm64.tar.gz"
      sha256 "5c357ac73b37899319d0dbcb1acb2904916d0c8b46f424203afcd2b08024e4e5"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.3.0/toolu-darwin-amd64.tar.gz"
      sha256 "3ae18432b917aaf9f5ddb2cf0dbd7e4227bc5b9328818ebc815e1e518d29a986"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.3.0/toolu-linux-arm64.tar.gz"
      sha256 "fd0d7def1071cd31123102376ef91ba70a67d2eb02a9306aa3217136a0486202"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.3.0/toolu-linux-amd64.tar.gz"
      sha256 "f6b2aa7c73ce88800c7395bbff6bffeec50e2f23d4caffb205c20da173824864"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
