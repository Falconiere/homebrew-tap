class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.11.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "618fbece1c375c48964e7c26d9b4d265f4bfd8945fab9f0072854811c24015fd"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "304b53714c597304ea762de90499c8ab749dec3e8af559a455ef64378280f0a3"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "fe1635df39d39c9d07972410a325b0a148179b236d088608a2c9e25ed6e7e098"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "7597d50b6c84dccd67d750a8c87ef79e6637e3fc166cbd5ae9109cb2d4e88e04"
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
