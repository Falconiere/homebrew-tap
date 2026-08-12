class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.8.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "6635a82d73f6b5db6a14c3e0d59e7b55969b167a4e8ca06f9c26d9b5764f2c0a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.8.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "5f7687c64400f2b253492fe2edfb3b03b333b6ed3eb781420c6e1032106ac88b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.8.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "f8f6fc1bc9e2a6be916362e1af2a1843edf77bfd31fe02008e61f41a86ca5c90"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.8.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "2f6f4c18b5e8d7c2d91d3aabc6a64898123b429f1defe1ae50bd56fbd6bccdb1"
    end
  end

  def install
    bin.install "toolu-runner"
    # launchd plist + systemd unit — optional, only used by --service installs.
    pkgshare.install "scripts" if File.directory?("scripts")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/toolu-runner --version")
  end
end
