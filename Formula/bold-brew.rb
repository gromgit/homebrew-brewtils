class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "13b4ed2117beca0232afdc14bb7d15468fa0773c08aeea97d7aa2810389bb395"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/gromgit/brewtils"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "4ef128a6aec4e62faad6553671daeb25b2a7dbdbba1f864c620838f516d59635"
    sha256 cellar: :any_skip_relocation, ventura:      "4dcd7096735e348d04e9f999f5905be8202a33a3e1316f8efaa2401a20dbcb50"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "934b2ef4bf8ec901ab727ec8ed859ef84340b219713251ae27337ae13e4039c2"
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
    input, = Open3.popen2 "script -q output.txt"
    input.puts "stty rows 80 cols 130"
    input.puts "export TERM=vt100"
    input.puts bin/"bbrew"
    sleep 10
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Bold Brew #{version}", (testpath/"output.txt").read
  end
end
