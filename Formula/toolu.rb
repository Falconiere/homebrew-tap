class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.4.0/toolu-darwin-arm64.tar.gz"
      sha256 "7089dea9e6e679bcaafcbbfa2cfba4b07cbe7ca817dc8c7fd70cefe2b5c6ba6d"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.4.0/toolu-darwin-amd64.tar.gz"
      sha256 "14a8cd5b984e2c8d61edb541736702e4f4ac2e395573c7eb59a00119c2375a9a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.4.0/toolu-linux-arm64.tar.gz"
      sha256 "b3a897923c611174505fd2ea52ae164548550b2c8b5dcf83fd1acc5bf9e41651"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.4.0/toolu-linux-amd64.tar.gz"
      sha256 "fa28f5922211338131fe39cbc71b3e8c81fced08c254080c0fbe8cf9e9efb1af"
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
