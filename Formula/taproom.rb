class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "311a7a3fb39cfbf478bd0a9ac2c6b5cc5fc509383edad223b119ec89f7ef66b5"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5d89d721c4a4d86ca331a67c1585cf46237b1937e7561bd506ea8259c8e9d50f"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "448b9ef4f2ee03856b9430ae84162a2d5eb4b938f6a8b84497cba4657824fe96"
    sha256 cellar: :any_skip_relocation, ventura:       "7f2938164f0b702b49f7b522e535aa38c5661c4cdd7ebe3e211899bdc2a33640"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1d78637eb11dc2366586096b800a3ae26574e432f478445781dfb7ef4d6a54d3"
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
