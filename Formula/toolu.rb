class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.2.0/toolu-darwin-arm64.tar.gz"
      sha256 "4ca35f4b1112d8171b69d005727e7d7ba0c45c36a7d2c370638ae3f72310495e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.2.0/toolu-darwin-amd64.tar.gz"
      sha256 "6b5415ce5d0b1e506344f2de963db9806e74b120883b47100f97bf32e2da39a5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.2.0/toolu-linux-arm64.tar.gz"
      sha256 "3f705e2003cd492b914a17accc7d54756ba84ff2a2941a0a0fd06861e1e09917"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.2.0/toolu-linux-amd64.tar.gz"
      sha256 "f571bb5bf4437b0195756028bcb550c715735dcc59cb014b4eae413d35ad101e"
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
