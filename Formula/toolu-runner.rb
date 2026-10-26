class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.13.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.13.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "9bea9335e3f9e99e0f4585b438c9412d7679904315937b7416768a27b90687d3"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.13.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "40b10c2e9ee5d0f959f485dedba77aae48ae42452b127c4bd25d75b5a13084b0"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.13.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "0f292f44942dbdd5b8231870035510c48dccabd070bfe78c4d427ae27651e367"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.13.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "7102fa4e68c772baaf4d4a2cbfb76d7b3df67549a9711d72626e8f9cd9a7974a"
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
