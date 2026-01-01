class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.2.1.tar.gz"
  sha256 "ec424e255ee90cdb2ee425f08898fba8587b145d8398f96cba63eec7b21f40ed"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "60ed4a85a6430b7c3dec3dd59cbf8a6c6ed0e0c05870bcc1316ae0fea938f5f9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bb30e8943b246c5c2a48c69ecacbe7aafc9d884328f1968bb54a3fd3860c6ad9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d6838e524bdeb2c3ecb3b702cfe404f481cbb0d7c69232b442997254f0004d24"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d136b83505772440aa7a13796e72fc34b5a8e310cddb4d4947c92152306670ce"
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
