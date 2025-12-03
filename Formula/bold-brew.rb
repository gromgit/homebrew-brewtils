class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.1.1.tar.gz"
  sha256 "4416f2fd52909324fb59a1d09860d749dcb8b232abdf267a66a4f9f26f3a2645"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "bf6046c9334fed0efcd6af0e7ec38b9fc5fb4f739b56642c67f4e62615e2261a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "251280535f8b5586d80812b0f5e8e6ad7ad55dbac2cf8b82e6e3ead1efadda87"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "62905f04c0ae626901b19fb8af4e7be5e7a6e606d4aa17a1102a3aa637f60885"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dcc7ae04c97a7401a957b56bf95e7291b281a718bebeb501d4ad85d4e8c0eb68"
  end

  depends_on "go" => :build

  def install
    cmd = "bbrew"
    ldflags = %W[
      -s -w
      -X bbrew/internal/services.AppVersion=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "-o", bin/cmd, "./cmd/#{cmd}"
  end

  test do
    require "pty"
    require "io/console"

    PTY.spawn({ "TERM" => "vt100" }, bin/"bbrew") do |r, w, pid|
      r.winsize = [80, 43]
      sleep 30
      w.write "q"
      assert_match("Bold Brew #{version}", r.read)
    rescue Errno::EIO
      # GNU/Linux raises EIO when read is done on closed pty
    ensure
      r.close
      w.close
      Process.wait pid
    end
  end
end
