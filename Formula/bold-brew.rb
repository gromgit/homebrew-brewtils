class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.1.1.tar.gz"
  sha256 "4416f2fd52909324fb59a1d09860d749dcb8b232abdf267a66a4f9f26f3a2645"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f06a86c146c35b42b056cebb7628b264df723e0dd557cf9019b8ceb50a3ddc8b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "21ecd34340e960c60906380163e45bce2602a88849a783b5328261c7a36ce917"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c89233c3fc503c54bb717498429f539ee350f9131fd5d24e406959a980865d6a"
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
