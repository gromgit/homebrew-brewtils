class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.2.0.tar.gz"
  sha256 "6897d9eefd4355cb8160379138b7b96fbac9d647a51f3c43427fc3904e9b2dda"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1e086447a08e08680c047a2f27ba50aba4cf6f1fb8e9bfa9a50a555ecb9c68e2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1d87944a45993bdabd45af6b8f9d22fe496543c94225cc47be91223985cde126"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6f1ba6add28f012bac4614870417f49db11dd256509085a5bd455a2f666e5319"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3ab88818604a7209dfcb0ace1c657589e9cc3d115ea66fc9d89462022199ad11"
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
