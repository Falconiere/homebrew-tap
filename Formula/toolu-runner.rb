class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "ec88ebe4887e3dcb484506cfa72a9f444dbe8173e09aabc32b86048a1002fcb1"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "c87ce0ccd629808d0d37a735441805255f4855bcddc94dc0efa16e37b6f504ae"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "e30acde32e2e2e84a8383a3fc1b2afefd861049c72f928853dec91c97a0aeeb4"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "5a771d8e0df2005312a293a9c74236baa2ed8f80576a311ad8d0fe065339475e"
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
