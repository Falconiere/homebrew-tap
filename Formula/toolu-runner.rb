class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "a06294ec05425a575070519ec52966c9555c2076813438e492ae5a089ea9b7a2"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "96f5512c8ba207536fc9e820f5df46895b1fd0a9d0a666a8deaad4607739b6f5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "cabd1573e42d0559b67d3b3b972b4bbcb067aad7588e13f965bc2419620c70c1"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "04a46852f6547cc5f25128dd3ecc027687884594e146a40d2af38ab8dfaa20f8"
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
