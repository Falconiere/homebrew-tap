class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.1.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "b5428fbc387ca263c29f9110cf499a63165012d614ffe3befad1fe17675da304"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.1.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "111ba765ae8e9fd52fcd2b32840749da909357ea91170e31854fa29d509eebdb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.1.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "aae6602e11ee675a11ab506be41c7d86fc7a6fbf417c2314386b30163c80645c"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.1.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "b7a3c349b6ba71c596367329d0acbbd44d4b8f7379964b2bdf7982142f6d7232"
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
