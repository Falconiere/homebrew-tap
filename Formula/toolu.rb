class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.7.0/toolu-darwin-arm64.tar.gz"
      sha256 "8616526f31e45f53c4f736eafdf00b5d7738bc15b47656785a1a750b35587fc6"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.7.0/toolu-darwin-amd64.tar.gz"
      sha256 "24068a88ca8b786b299cf484bd57b1dbc6f04536a3f4e0882e6404f3cd766e69"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.7.0/toolu-linux-arm64.tar.gz"
      sha256 "77289cd17c922822623e7759f24bec4be4768ca1d6de8a189affd419ee9b6130"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.7.0/toolu-linux-amd64.tar.gz"
      sha256 "1930f6ee61c1035371ce34cdafef6d6b4a9337686de07ddd194dded5a8644f42"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
