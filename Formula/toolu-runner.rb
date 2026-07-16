class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "59ec84e5262a7a3c3499a7bf0370bc33f0b211e8d41e3da84999156de3e308bf"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "dd19ae8f3f85ceafb50e5e5ce2f6c6deb6f64612d4ac9dfe8c002352ee7136be"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "0088b6068fdf71a9d1e35462e7b9018b3f3825241a50927ba5f4a83160568471"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.5.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "250c15b6524223606efc428997fc72202882906f5cf18556880a7ce8f0ed27b4"
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
