class Toolu < Formula
  desc "Code-quality rules for coding agents, as one native binary"
  homepage "https://github.com/Falconiere/toolu"
  version "8.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.12.0/toolu-darwin-arm64.tar.gz"
      sha256 "e42e24b66371025ed3cf27f3e8f535104152251a859e3cb358066d7910fb5d11"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.12.0/toolu-darwin-amd64.tar.gz"
      sha256 "ee51dce9b4fa42feb5da05f7c5fd9d92cc3509f83d1f89966779ccc8dd6e5845"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Falconiere/toolu/releases/download/v8.12.0/toolu-linux-arm64.tar.gz"
      sha256 "111618d22697d5977878fdbe1bd088f8d4c66e816d408fc336047478ca697c21"
    end
    on_intel do
      url "https://github.com/Falconiere/toolu/releases/download/v8.12.0/toolu-linux-amd64.tar.gz"
      sha256 "c3f31326d874add9d2266cc300f1743a5ebb256173831076000e0aa806bd1c79"
    end
  end

  def install
    bin.install "toolu"
    generate_completions_from_executable(bin/"toolu", "completions")
  end

  test do
    assert_match "toolu #{version}", shell_output("#{bin}/toolu --version")
  end
end
