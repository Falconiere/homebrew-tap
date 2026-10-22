class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.1/toolu-darwin-arm64.tar.gz"
      sha256 "9df13c2df78ad37035882683eeb4f07766c51c74151ef69707d9d30061d732a2"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.1/toolu-darwin-amd64.tar.gz"
      sha256 "749f8895628302bcd85356131a6c07ea099baf547b6cff631c541f6feb63ec4a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.1/toolu-linux-arm64.tar.gz"
      sha256 "b80db6fd5b4d4a8a666e76b87a2c65b5d837a7a9130eeecb1e41a31ab301fdea"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.1/toolu-linux-amd64.tar.gz"
      sha256 "b39cc6c70899c7e4802388b399cc513a82a79397cf4fe3152bff367fb58db1da"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
