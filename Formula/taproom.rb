class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "e4fc7e960fbb9bdca6f255f19e5edf8aa8be78925a8e36ab7b1344a7bb3dd505"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "29aff9222d247e27b682506eebb158833c5545dd6d0fb36bbc4b7c56e6282704"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1105a1315df4a53d2cd81059096f81ae8f35e748b14c8921e84c918eef19f958"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "181b8e3be4289ea96a0d1c40f7cde7d0e4f9dffa52269b531e9305613bfa3eff"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1f4a3452024c6cf6be13f661376751d5f142c158318f1bbfb14f36903f6d6ed1"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    require "pty"
    require "expect"
    require "io/console"
    timeout = 30

    PTY.spawn("#{bin}/taproom --hide-columns Size") do |r, w, pid|
      r.winsize = [80, 130]
      begin
        refute_nil r.expect("Loading all Casks", timeout), "Expected cask loading message"
        w.write "q"
        r.read
      rescue Errno::EIO
        # GNU/Linux raises EIO when read is done on closed pty
      ensure
        r.close
        w.close
        Process.wait(pid)
      end
    end
  end
end
