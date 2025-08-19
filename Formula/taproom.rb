class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "e272fa779c16303159068102840dc993af226f7d1c6b1ddd7b978a71ec2bf77e"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "868d57e013f09e48b34fe6a68f858fa681174828083c432b006bd260bcb161bf"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "491e40a7db18af7544daff623e233462331475be1fa269b07bdf69f76f553f29"
    sha256 cellar: :any_skip_relocation, ventura:       "0eb48920225cb22da63e66a597b0bc41d722bed5425fc1c3a7cd4c03bf60a373"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b08bf7808ed7472d145ea2eebf023f3b369e8b45318096998ec60481b42dd5f9"
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
