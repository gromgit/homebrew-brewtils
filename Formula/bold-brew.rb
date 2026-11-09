class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.3.2.tar.gz"
  sha256 "2e22f351e9726128746a3f2f8591e9d1a2f525cbe1aca6b0af6a20f6f909faec"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e9a724b611b81f0cc1b673879388020a2357765a554cbb9c57fbdfd34ed47f28"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1d816a89b4564f2a69ad820385e1ed416fca870961bed73310b3050dc12c94a1"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6d6b91bb1e53bb482810b8ce9b39117a09720d1f9a5b7d62c51921d7f0fc8e7b"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "3809cdd59805e73042dd8ce01f036404205618c42c3f4ce437b1c83d7a921e2f"
    sha256 cellar: :any,                 x86_64_linux:      "53022680cd501ae52b558afca30d9870856308814b0ac8827b2fdabc434ff20a"
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
