class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "10.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.1/toolu-darwin-arm64.tar.gz"
      sha256 "de07f32a1b363de267cbe3ae31cc8dd7ccffb40f9fa4fb354a027d8cf0377cc9"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.1/toolu-darwin-amd64.tar.gz"
      sha256 "df442186e2070358d49b48bc040a8af70869494097f4b9d29a89a76f3d750e3c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.1/toolu-linux-arm64.tar.gz"
      sha256 "a56a09b6a1a091a6e4c3ea8af165515779cc6d965722b068dadedef11ec35c1e"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v10.1.1/toolu-linux-amd64.tar.gz"
      sha256 "786801eb126d4feac296af731f0485c6c6bbdb7b6b65ee52383a390ee8ec68e5"
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
