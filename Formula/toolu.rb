class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.0/toolu-darwin-arm64.tar.gz"
      sha256 "ccdab052a5afa1988c840f90c91f8704026c39f537fc46429edef07b614b906a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.0/toolu-darwin-amd64.tar.gz"
      sha256 "7208a4ab2891ebd4568aea3de5e575f8ced2ac1dcfc0a31f0341b0a722398481"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.0/toolu-linux-arm64.tar.gz"
      sha256 "2710167c3d8c968b5a29a3e7268ab6215f21c8725448c72d9fce6306fed9ebaf"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.0/toolu-linux-amd64.tar.gz"
      sha256 "0bc25a6a41b818ecc9793e63e8dedf34e62178d57eb83569a343351713a127fd"
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
