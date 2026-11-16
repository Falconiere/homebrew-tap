class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.0.0/toolu-darwin-arm64.tar.gz"
      sha256 "04bc4e9012ad58656401db438f136bfe66b832cf0d3fb608eb1a4c60a602854e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.0.0/toolu-darwin-amd64.tar.gz"
      sha256 "7c0b2ae940f843dfc595243f96283245319efcc6a4008f3eacc5fba7aab75607"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.0.0/toolu-linux-arm64.tar.gz"
      sha256 "d670de562ee6b1fea234c9c9ba2175a8342a40d40fcb3e39e6bc4bc12f6d7c54"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.0.0/toolu-linux-amd64.tar.gz"
      sha256 "3d392b0176e8d4ee844ab41038fcafefb8919cdf439b756e37963f9146cafa29"
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
