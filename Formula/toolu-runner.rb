class TooluRunner < Formula
  desc "Standalone self-hosted GitHub Actions JIT runner"
  homepage "https://github.com/Falconiere/toolu-ghrunner"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.3.0/toolu-runner-darwin-arm64.tar.gz"
      sha256 "de92a746497ca3405b985e3a7fa07638d6a4c75fd188380e008d0b0068d18641"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.3.0/toolu-runner-darwin-amd64.tar.gz"
      sha256 "af27e02ed3852fd0b63b525be880c36055698af86275f796c3927bae0c16b052"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.3.0/toolu-runner-linux-amd64.tar.gz"
      sha256 "0d72dadffd4603cf4b0ee4c7af3ef3a2656d99d1beafabc9dd9725844be106f5"
    end
    on_arm do
      url "https://github.com/Falconiere/toolu-ghrunner/releases/download/v0.3.0/toolu-runner-linux-arm64.tar.gz"
      sha256 "07ef0138f932b6892af85941d589a564acc78bc4c9fa85a75c921fabfb997350"
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
