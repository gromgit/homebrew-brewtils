class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "de2e98fd8a961222eb4e0b28fbc05e5c8f322c4cc34d3919407cafbe863af772"
  license "MIT"

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
    sleep 5
    input.puts "q"
    sleep 1
    input.close
    sleep 2

    assert_match "Bold Brew #{version}", (testpath/"output.txt").read
  end
end
