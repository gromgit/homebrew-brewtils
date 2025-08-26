class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "d8f94fd8f6fcf31a5890e4ee39650ac9a954cde55e4508ec798d4e65d088eb83"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e49d359cec08db2cd7357f969f054fcd482b43d5b071e42ad58e7d15e4c3d93f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f068d9495392308750cf5e83f34343b74ed350ccacc62649cdf0f73d188c0f99"
    sha256 cellar: :any_skip_relocation, ventura:       "1dede2f1f1ffb73b380a78c853c5f79f3387501f75165bc4b7ec3969bec296e1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f4d153b664a6ed2fec0bf065fbec13b0f52355f9fcc3fe9d6fac5dd6a911e3da"
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
