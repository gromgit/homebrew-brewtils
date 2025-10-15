class BoldBrew < Formula
  desc "Homebrew TUI manager"
  homepage "https://bold-brew.com"
  url "https://github.com/Valkyrie00/bold-brew/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "13b4ed2117beca0232afdc14bb7d15468fa0773c08aeea97d7aa2810389bb395"
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
