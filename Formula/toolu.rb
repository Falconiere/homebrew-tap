class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.8.0/toolu-darwin-arm64.tar.gz"
      sha256 "3c1710ccd6046377570009b2f0510cf257e8a2be7877317a0b71501318c67b4c"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.8.0/toolu-darwin-amd64.tar.gz"
      sha256 "fbdf6f9f6232e0c51ad5ba7451e15cbffeea85c8d3c6fdac803a814af1d42d29"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.8.0/toolu-linux-arm64.tar.gz"
      sha256 "21e82971f75ae7f5bdd5e5d1f6a9d43482088cd5b60c36d7c36804cb793275c4"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.8.0/toolu-linux-amd64.tar.gz"
      sha256 "e168fa93dd9c57d2f102414803261ecf17a5224d14211d064c4f58bca09493ca"
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
