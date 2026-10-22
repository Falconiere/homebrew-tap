class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.12.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.1/toolu-runner-darwin-arm64.tar.gz"
      sha256 "abc4ae9835349ef7c6d6cb1519b4711d1923582563f31d57d653b7ad0b9b9151"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.1/toolu-runner-darwin-amd64.tar.gz"
      sha256 "ce711b7b76eacdd199ac30ff926d8e1bae57c20a6d444fb257ff9b832e3736e5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.1/toolu-runner-linux-amd64.tar.gz"
      sha256 "a493f735c40e95d8799272cd0f870ee10e9e1e88d164f2d5764da4469eacca05"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.1/toolu-runner-linux-arm64.tar.gz"
      sha256 "a3e813745f0095c7831ac0e9d6ca5a3c183cd0528f8ca65d9344a617a7a99791"
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
