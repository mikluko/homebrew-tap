class ForgeOrchestrator < Formula
  desc "Orchestrate Claude Code, Codex CLI, and Gemini CLI on shared repos"
  homepage "https://github.com/nxtg-ai/forge-orchestrator"
  url "https://github.com/nxtg-ai/forge-orchestrator/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "4d46733d6c4954295a9563d275a97bfa12e0a5de2a8a7a0f2d7958de43966a78"
  license "FSL-1.1-ALv2"
  head "https://github.com/nxtg-ai/forge-orchestrator.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/forge --version")
  end
end
