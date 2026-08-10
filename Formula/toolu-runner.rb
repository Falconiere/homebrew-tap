class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.4/toolu-runner-darwin-arm64.tar.gz"
      sha256 "be9478ca42d1e9c0bf353ccd5e220b79901dfd41472802762b037454152ba5da"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.4/toolu-runner-darwin-amd64.tar.gz"
      sha256 "cbf4747f2e649ab6dd3d604704003c2cba0fb7df19cf3d552c23c25653c052bd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.4/toolu-runner-linux-amd64.tar.gz"
      sha256 "2e100ef33d5c05b868e53534128cfad14fd8981391a73f82c4b6a528b791d381"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.4/toolu-runner-linux-arm64.tar.gz"
      sha256 "a4ba4961443def2e2a83fabc01cc82b9f98cfdcccef05c62040f0c52b57ca0dc"
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
