class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.16.0"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.16.0/toolu-runner-darwin-arm64.tar.gz"
    sha256 "232e0c92e9a10a6bf9d31e6f35ab96a9aee7f2589353101bcaf967e2e6c0c631"
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.16.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "22c903c71439b1f8bbdb3a4cc8f5d78700a7b87c03106439cd5007b462914a99"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.16.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "b9b86f1b8d888ec7a929da2a97cbc2d095c6818f8367a1b80357ad9969e88483"
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
