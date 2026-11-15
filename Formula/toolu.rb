class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "9.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v9.1.0/toolu-darwin-arm64.tar.gz"
      sha256 "76f55b383a7664bf647182efc17f4e0966eb097ee724301b804aaaf4b8906ddc"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v9.1.0/toolu-darwin-amd64.tar.gz"
      sha256 "d95fe01dea8343670676941142f16c9ab744be1ae9d03324cef68c01d8f0f209"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v9.1.0/toolu-linux-arm64.tar.gz"
      sha256 "fed2883b8b58477c3e61af6850637ce648701d812334f5b34fa87ba322671e49"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v9.1.0/toolu-linux-amd64.tar.gz"
      sha256 "93d91dca250f5684af1b7de9c06c4429c6b6305b051fd4047aad7d513fa98c6c"
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
