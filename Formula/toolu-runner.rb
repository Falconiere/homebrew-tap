class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "9276de1b3c3451aa5229707fcdc0dcbf0108a126eba3231ded5a2b2850584434"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "c5438d24686dc68a8c970e8ac715592092ae688c68ab9ea1d129915fcb01c369"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "bd2617bf43ca3b3d8d3a290fe95e557ea0bf0c81d24b33c3798030a52c2e8a03"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.12.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "0ae57faf2dc1ef9782b6d73673aaf27a2a607595dcde84efabefd0acf85718dc"
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
