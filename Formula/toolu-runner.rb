class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.9.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "4ea1bcabc80d23ba85b486c1be23b39e67694a68f5ae2d83bc7b02650f3fb320"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "df52333dc6446f539a7e65d0b63ee96ae039d11d2e01c104bde8b0a101ba8d95"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "0b8d54e22b68d2f7a3621a45f8a5e9fe93d32ae438eb5a7670e2edb3481a639c"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "40666b3d5c46a60479c7dece921dda3f368fed39711eef5b8c8478f864f2407c"
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
