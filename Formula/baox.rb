class Baox < Formula
  desc "Run commands with credentials from OpenBao, plus credential helpers"
  homepage "https://sarak.sh/mikluko/baox"
  url "https://sarak.sh/mikluko/baox/archive/v0.3.0.tar.gz"
  sha256 "16779ff509fdecb4f3029b178567b53e704f463e31271fc041aa63fe33e03b87"
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
