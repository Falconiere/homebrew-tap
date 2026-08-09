class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.2/toolu-runner-darwin-arm64.tar.gz"
      sha256 "85ccf607136e9375fdd90772f14a47db367b5fa84125a4d9205a81a40bd21c18"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.2/toolu-runner-darwin-amd64.tar.gz"
      sha256 "4a1cd42a44244067bfb4ad2604c4f46dc90c1559fe1d6bd73eb7115b4739173b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.2/toolu-runner-linux-amd64.tar.gz"
      sha256 "6b03aef084c8e46c09de856d941fb9634d368a51dc7aeae044e6460891291a78"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.2/toolu-runner-linux-arm64.tar.gz"
      sha256 "07daf84e4b76ac422c6531b84a867fd12ae9a8264fd1bd84d30d80d56854ce3d"
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
