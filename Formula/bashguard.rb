class Bashguard < Formula
  desc "Claude Code hook denying shell file writes in favour of Write and Edit"
  homepage "https://github.com/mikluko/bashguard"
  url "https://github.com/mikluko/bashguard/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "53a23b508be496c13755ef82817a018cec8d8b826f56e2e3aaea9422a8185698"
  license "MIT"
  head "https://github.com/mikluko/bashguard.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    edit = '{"tool_name":"Bash","tool_input":{"command":"sed -i s/a/b/ notes.md"}}'
    assert_match "Use the Edit tool", pipe_output("#{bin}/bashguard", edit, 0)

    build = '{"tool_name":"Bash","tool_input":{"command":"go test ./..."}}'
    assert_empty pipe_output("#{bin}/bashguard", build, 0)
  end
end
