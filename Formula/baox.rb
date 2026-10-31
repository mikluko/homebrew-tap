class Baox < Formula
  desc "Run commands with credentials from OpenBao, plus credential helpers"
  homepage "https://sarak.sh/mikluko/baox"
  url "https://sarak.sh/mikluko/baox/archive/v0.1.0.tar.gz"
  sha256 "73734e160af091fd9bf8ad7b893f410bfb919192d69e57180800fb1a48a5960b"
  license "MIT"
  head "https://sarak.sh/mikluko/baox.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X sarak.sh/mikluko/baox/internal/cli.Version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "."
    generate_completions_from_executable(bin/"baox", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/baox --version")
    # With no bao:// reference in the environment, run starts the child without logging in to OpenBao.
    system bin/"baox", "run", "--", "true"
  end
end
