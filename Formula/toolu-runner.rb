class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.12.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.2/toolu-runner-darwin-arm64.tar.gz"
      sha256 "3f53a24c629a6c4c5343e8f9dc3aba2227c8030918c2e9f4c1b58ee8d99c9334"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.2/toolu-runner-darwin-amd64.tar.gz"
      sha256 "147e4cf7f0c84a7886e0cf182e1c0145aa18933946a811f6719f917989beb019"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.2/toolu-runner-linux-amd64.tar.gz"
      sha256 "9f2319061166fefd4f1f2d38f5d1191e627f4e4fd415da63fd09175ae76c60fd"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.2/toolu-runner-linux-arm64.tar.gz"
      sha256 "a2bc36df35777f85df2d27310983513af2a1c1ca5b4e12b5ffbc357a062e19e8"
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
