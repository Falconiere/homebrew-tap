class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.11.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.11.0/toolu-darwin-arm64.tar.gz"
      sha256 "3680cf6df74227be962792b60f53adf766ac9bcbba6d98534fda6e48215da0b3"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.11.0/toolu-darwin-amd64.tar.gz"
      sha256 "8f2b02da0020e75d9603c0b9cf67040a41d7d198295533d1cde0d6f3eb0b207f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.11.0/toolu-linux-arm64.tar.gz"
      sha256 "a4c09489e2c773a739025f3b4780ccb4073eb9e961f6f2e43398a9882d1b79cb"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.11.0/toolu-linux-amd64.tar.gz"
      sha256 "8129948eb625927e355bf074af8f187acfcb1e5a9e65eb61c0d347b77bc64d1c"
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
