class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.0.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.4/toolu-darwin-arm64.tar.gz"
      sha256 "6258f5f05dbbf60cccb7b95eaba87cb82373bdb49d65da07b9352a96e6e78516"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.4/toolu-darwin-amd64.tar.gz"
      sha256 "07a7e384de0fdba5d6df0459b4d953a0c7af3f7977c83eeb3234c16b2937546f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.4/toolu-linux-arm64.tar.gz"
      sha256 "13fecdb0f78536b4e1ee887e4df16cc513da83cb4853e26338b98750507a6b8a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.0.4/toolu-linux-amd64.tar.gz"
      sha256 "493561061000dd4220c8e32460060a9c5d0a451d8c8882d46421f6ba06c36c9f"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
