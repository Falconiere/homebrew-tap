class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.4.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "8e397ed1d5739b96d534c4555a52106ed1726d30982c2b6db86fa45cf4e0f5b4"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "5c30e2ea4a4e3361fef36134a0810237380c95fe73d8f2c4a07a84386dc9fc72"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "2574c288afdd0ee26e4178f0d45474c93c9d49efaa99ed8418e35d21baa3483c"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.4.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "c776062d52da2ec2ac7f822f11d5afe5266ecff9b9ec5629ac8ce55671773b2e"
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
