class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.0.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.3/toolu-darwin-arm64.tar.gz"
      sha256 "c6c11079c1fafa8e9051a62b8566d77da9a9be9973c5aafcf4244bf87d69ae96"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.3/toolu-darwin-amd64.tar.gz"
      sha256 "d0768d66b20bb668a172ec311b6d42e621b8afe70ab4874bda205cd661c025e0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.3/toolu-linux-arm64.tar.gz"
      sha256 "29389fde2f5772aae665b8d3db4053f2e0b02f55f1a3594e800abea8331cf8a0"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.3/toolu-linux-amd64.tar.gz"
      sha256 "072a8d145d6b3802f22c6e854245d06ebb4bc3ebf693311d992d2d07c053b975"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
