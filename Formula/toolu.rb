class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.1.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.4/toolu-darwin-arm64.tar.gz"
      sha256 "03ce73f3ce9fabb31233248ecaba0652a3add2b5a66109978d0c84f2940e0d73"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.4/toolu-darwin-amd64.tar.gz"
      sha256 "7f16236517f1daa2d94ced29a611e37b05740bbfa388aca1de3ea1334e368ba8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.4/toolu-linux-arm64.tar.gz"
      sha256 "66172d3c8cda7831996cd14957866ef6d2a18ef1dc02539668a0e40fe40bb568"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.4/toolu-linux-amd64.tar.gz"
      sha256 "508609918e0f31109a57f1782892b4b835fc6e7fa0d8c8f7d6efe0eef8308f61"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
