class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.7.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.3/toolu-runner-darwin-arm64.tar.gz"
      sha256 "825080d5a35f9db9583e7c673ff48d1e3da629dc72073ea1c79fa9edba724da4"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.3/toolu-runner-darwin-amd64.tar.gz"
      sha256 "91d41f4e1f39f69517c11d460cff40ad0c67ef3c7ef53d81a7e31b54c4421ada"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.3/toolu-runner-linux-amd64.tar.gz"
      sha256 "2fe422cbd2aab61377296b1023b7f98b9c1a537486636a45a6dddeae8979d4b2"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.7.3/toolu-runner-linux-arm64.tar.gz"
      sha256 "1d968c91af966d621b9b8d8a58a81fa933eb08df7792353c0900947352f0f143"
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
