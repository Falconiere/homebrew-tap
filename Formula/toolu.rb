class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.10.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.10.0/toolu-darwin-arm64.tar.gz"
      sha256 "5e7d43c18fc270068246b78172338f8c81c157d8942ab4c3ea530c462d99b0e0"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.10.0/toolu-darwin-amd64.tar.gz"
      sha256 "28edab4c976ec9ccdf9dfced0cf211dbe84cc8fba724c0a60f5ef7a80d56cfb0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.10.0/toolu-linux-arm64.tar.gz"
      sha256 "e07d686f0abd1e79ecf36381c444d311248b10b0c900a839adbc134059fc582c"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.10.0/toolu-linux-amd64.tar.gz"
      sha256 "2aacefb2ed1e47600e425e2426ef1132eaf14b56eefe5c05b7286988f663f90e"
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
