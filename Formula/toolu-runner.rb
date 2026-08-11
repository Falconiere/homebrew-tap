class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.5/toolu-runner-darwin-arm64.tar.gz"
      sha256 "17ccd008f78e8f1b4e014e79fd7291ddad0a5791aa6bf85e360fc6f36e3053c9"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.5/toolu-runner-darwin-amd64.tar.gz"
      sha256 "8252ba9851d7de141da1a6fb4f7fe58d45d68654495cd390786682eae0493a8c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.5/toolu-runner-linux-amd64.tar.gz"
      sha256 "9582ad07e13657168804d5420121745a8fdaa2299cb4acf4b067557f73a6cd21"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.5/toolu-runner-linux-arm64.tar.gz"
      sha256 "1916daf3670c694db8f317af86c655dd1f1d3e31f99caa53a781d8326077b059"
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
