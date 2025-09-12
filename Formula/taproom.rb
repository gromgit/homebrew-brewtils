class Taproom < Formula
  desc "Interactive TUI for Homebrew"
  homepage "https://github.com/hzqtc/taproom"
  url "https://github.com/hzqtc/taproom/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "a242978f0d42a5613e39b0b8825e611ea5b24dea78fc840118ac3a665b3d0130"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "4a64a83ebfe0e7fb6eefad3649503f6af902781b058ddc1bd68304e099f7ac98"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4317084dc6fdc05b8fc687c8c05dd5798b8369164d8ae9f75add56d4d1b17075"
    sha256 cellar: :any_skip_relocation, ventura:       "03ff7cf96377be9113306b74a1753024fbdb7c38af2767011cf1c59802122297"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a9b336aee72d80ed4f712b177ec8a36cb4a9a08408c6e691006749f2710d5149"
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
