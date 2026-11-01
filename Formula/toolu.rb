class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.9.0/toolu-darwin-arm64.tar.gz"
      sha256 "d0cc80229495d780bb0565a45f55ac0c4ad1f539c5cad8030d29a7251acf2e88"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.9.0/toolu-darwin-amd64.tar.gz"
      sha256 "e48fa1d27263eda6cf7e8d71ee178caa65845794aad0eed37c93798d1656b731"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.9.0/toolu-linux-arm64.tar.gz"
      sha256 "b613444a378473152b6fc947dfdb0f4980cc70a850eab16fc8d3ce42f2db4d6e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.9.0/toolu-linux-amd64.tar.gz"
      sha256 "22f158568e8c769324bd89d76fc0ca032384144b8b97ac331ddf5948c5b995a2"
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
