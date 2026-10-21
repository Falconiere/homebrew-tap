class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.11.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.2/toolu-runner-darwin-arm64.tar.gz"
      sha256 "6f0ddd73d2daae49967116eacb84cb492e2e5085309a8a097f8e5c6cab681b1a"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.2/toolu-runner-darwin-amd64.tar.gz"
      sha256 "04c42c75dd0e8784916fa561297f904bb543396103f385f3e82a6dd1d0c7e03d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.2/toolu-runner-linux-amd64.tar.gz"
      sha256 "ff08854e476ed3979a703064bf3e31ba22bdcdf9625d126e60f983d2ddd353e3"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.11.2/toolu-runner-linux-arm64.tar.gz"
      sha256 "8bea643a725faef69408002d8f8211b8555f56cefab3287c368c4e36ad027e65"
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
