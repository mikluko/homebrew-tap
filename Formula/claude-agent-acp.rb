class ClaudeAgentAcp < Formula
  desc "ACP adapter for Claude Code, powered by the Claude Agent SDK"
  homepage "https://github.com/agentclientprotocol/claude-agent-acp"
  url "https://registry.npmjs.org/@agentclientprotocol/claude-agent-acp/-/claude-agent-acp-0.64.0.tgz"
  sha256 "a62019ef561a189ad5397b194f52a223157324f0dbfcba944856c95faa771324"
  license "Apache-2.0"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/claude-agent-acp --version")
  end
end
