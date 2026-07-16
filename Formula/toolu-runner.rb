class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.5.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "9b74fb82accbc63f49ce435e08484b219e3e9ee698829f562655aa8012b25e74"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "f67ab073bda98712fa088aa8930f9da9f432ea368f7931f97cd9c033cd9b0e25"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "5d9601d33b9b28a17287562a27f5404dc47966b7d7469a892600370b6cd67244"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "f79763053e91f6cb04a44ff83051d134a78962cacb8e442a23d967ce2fa25e4b"
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
