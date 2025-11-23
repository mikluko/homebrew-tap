class McpProxy < Formula
  desc "MCP proxy that connects stdio/HTTP clients to remote MCP servers with OAuth support"
  homepage "https://github.com/mikluko/mcp-proxy"
  license "MIT"
  head "https://github.com/mikluko/mcp-proxy.git", branch: "main"

  # Stable version will be added when first release is tagged
  # url "https://github.com/mikluko/mcp-proxy/archive/refs/tags/v0.1.0.tar.gz"
  # sha256 "CHECKSUM"
  # version "0.1.0"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/mcp-proxy"
  end

  test do
    output = shell_output("#{bin}/mcp-proxy --help 2>&1")
    assert_match "Proxy for connecting MCP clients", output
  end
end
