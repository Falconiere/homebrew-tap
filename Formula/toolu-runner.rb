class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.6.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.2/toolu-runner-darwin-arm64.tar.gz"
      sha256 "b0c7996969c4413ff0cedd2d1e1a3b2b051b07e7e7fcf17055bc8e7398688479"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.2/toolu-runner-darwin-amd64.tar.gz"
      sha256 "1ffa2f1861fd62889a3d42dff9005e989e72e042ede67a0bd9e68aeb2cfdbf66"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.2/toolu-runner-linux-amd64.tar.gz"
      sha256 "34e99f4ab849fba2b0c4a1605ade3711766b389c068b0e09183522f0721254e5"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.6.2/toolu-runner-linux-arm64.tar.gz"
      sha256 "7d03a0cebcc3487be796aced59e1c87cea7671095d15b344820d020e7b3aa88e"
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
