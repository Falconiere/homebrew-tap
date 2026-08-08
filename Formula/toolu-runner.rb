class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.6.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.3/toolu-runner-darwin-arm64.tar.gz"
      sha256 "6c6fb93b208146a872dfa5705228d7392348a09e314e225231372177964097ad"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.3/toolu-runner-darwin-amd64.tar.gz"
      sha256 "76bb4442d2ec87121546a2d3071c27d5bc0394fd3b72fc99dafd6ec3bbedc7ae"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.3/toolu-runner-linux-amd64.tar.gz"
      sha256 "d599acc077f3ee9ac2854fdcc315fe3ebae119ca110d902464cd48964fae488b"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.3/toolu-runner-linux-arm64.tar.gz"
      sha256 "82c5ea6128bd5cce28533a011767de3da1372f84f97a29cee63b0396fe7608f7"
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
