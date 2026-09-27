class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.10.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.10.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "80e4706ee090330a3cf27d589e7fa3158faece7765f204eaa1c9f39cb93efab1"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.10.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "449dd2e5137b9a9e520b79a658ca4cacb1005d273553a7885d94f6046800e9fd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.10.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "d24e26056bf4b3cc516fc0a08a3e0b5987651a29a14bc596db892a20df00741c"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.10.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "f915bae985fc950b55ea63464c22db2d25e0ed0f1f7462787c1b7e934a420cf1"
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
