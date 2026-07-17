class Claudectx < Formula
  desc "Launch Claude Code with provider contexts, kubeconfig-style"
  homepage "https://github.com/mikluko/claudectx"
  url "https://github.com/mikluko/claudectx/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "671ef20a673e07e39db13614c1a8162a54fba6151d4db2bd88128f19e5c5cf1a"
  license "MIT"
  head "https://github.com/mikluko/claudectx.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    assert_match "claudectx", shell_output("#{bin}/claudectx --help")
  end
end
