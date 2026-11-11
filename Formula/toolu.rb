class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "9.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v9.0.0/toolu-darwin-arm64.tar.gz"
      sha256 "bb5b894aa1464b157f0b358cbb76e0484e03f2ee624c87b249e26a4ca9784dd4"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v9.0.0/toolu-darwin-amd64.tar.gz"
      sha256 "d7a6bb0a9b149bdd28c6dbf881f35262c5fc6aff7c345f21a93cad43c30fa625"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v9.0.0/toolu-linux-arm64.tar.gz"
      sha256 "2e5446687c0486a76644ed71d9cfc836c6184e1577aa7980ab45f091636aa2e1"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v9.0.0/toolu-linux-amd64.tar.gz"
      sha256 "3401f15a6ceb29f089c2323a76d8209ea33ddbebfe2ec805928ac4fbfd802d43"
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
