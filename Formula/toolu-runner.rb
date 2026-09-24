class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.9.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.2/toolu-runner-darwin-arm64.tar.gz"
      sha256 "c3463b073c9389b05ca9ed0aaa5c4df73661bcd6e759da734d71e9412f375c6d"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.2/toolu-runner-darwin-amd64.tar.gz"
      sha256 "a1456e1a706c391bbe311c0eceb493150ee2e1425f11fb032c8c5538001a5c89"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.2/toolu-runner-linux-amd64.tar.gz"
      sha256 "99c45f695c3f3c8c5ef42692cd606d3fc571a52b93a5d82e9003b63015efa77f"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.9.2/toolu-runner-linux-arm64.tar.gz"
      sha256 "d7cc58e7ff52daa0c7c179aca879c6586fee258c09ef030ff8aa6f0fb21446e9"
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
