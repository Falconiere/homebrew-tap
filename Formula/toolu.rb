class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.1.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.3/toolu-darwin-arm64.tar.gz"
      sha256 "f299d45af4b7d55d9e71bfa08c68822a6f67e688aa21384d6f3bbcdb6d22afb9"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.3/toolu-darwin-amd64.tar.gz"
      sha256 "fd85ef3d2c7cd878be300d40256163eeda3d64fe0596ef0d2f00fd307f32fa01"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.3/toolu-linux-arm64.tar.gz"
      sha256 "9dc0cddb846dbc3488aabb782a16760dc37cf9df803339ce5c506f1a743e0bbc"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.1.3/toolu-linux-amd64.tar.gz"
      sha256 "7c5c9725685efd4643c93b83d30e057f7064d75894208d8a5655baf9a42301c5"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
