class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "14984847ed56e5caceeae669c5779ebbe2a1deed581f1f89ee0167ca59cd45cf"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "ef438091e6e5b4f3758d510b99f3b06027a478915c26d006125f7b0869b402e2"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "7dd982757f53434b0ea6f22711442cc64aa3f696c87592ff9dc3d05d6e9ed284"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "6420aee7ae6486faebb9a0e93ff8c395f8ec9187fc1abbba65756b0dbf414ae4"
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
