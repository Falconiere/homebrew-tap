class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.2.0/toolu-darwin-arm64.tar.gz"
      sha256 "0d84d1b4183337c4689f734cac453207453ef0378e40bca2579e0094b2b5645f"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.2.0/toolu-darwin-amd64.tar.gz"
      sha256 "4befc504fe6de133e2a9fded6b9124455068fa5911e5098a7249ba7a8a073343"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.2.0/toolu-linux-arm64.tar.gz"
      sha256 "5675cba4b839867d215aecd34ade30abf3ff9bc4a83e384aad4985e9060eff78"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.2.0/toolu-linux-amd64.tar.gz"
      sha256 "5ac0635cca84765d794bdd146b90095aa391d6612607651ee7414789655170f9"
    end
  end

  def install
    bin.install "toolu"
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
