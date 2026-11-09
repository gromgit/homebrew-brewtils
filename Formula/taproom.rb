class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "85ee7660bb76ed9277573d2c856bcfebd3181b919edf3862e7f9e15d32097088"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "317a7a72efa9e9d55b733838882864f352cc8339990ee54ddbb216fda6ca1da4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "01720c3d5e0b5be25ebe976419aee1a9dc30342996d6faa7cebd3ae0b52534de"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3406b6bf192309c8d4e6e1279c14a15c5633b52c8274cfb46dd9713c06558401"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "226477e3ce62db77aeaf6e90d1b3c9cf908495ff93d8dda8fd3ba1722f0529aa"
    sha256 cellar: :any,                 x86_64_linux:      "680653a627bbdfef5881cea6b400169773fff6dcc021b20e6bf21dad6568dea8"
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
