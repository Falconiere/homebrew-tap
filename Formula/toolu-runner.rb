class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.2.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "7e443d39cc41b8feff824e7cb98cd76c18178525aa714c56a9723eb91ba801da"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.2.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "9e35a077def194976a63f6a3c95466b298de45018d67012a167556659c239301"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.2.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "99b824cd991bd43820777cbc2d39de83bb2cab4738d10ae3dd4c647325b65dd5"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.2.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "56dfa546f6e0821b20b0ea359f7851c2ec28e71b8b470288941802369845ba1b"
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
