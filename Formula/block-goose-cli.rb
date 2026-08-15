class BlockGooseCli < Formula
  desc "Open source, extensible AI agent (OSC 8 hyperlinks fork)"
  homepage "https://goose-docs.ai/"
  url "https://github.com/mikluko/goose/archive/2251cc5e853e584ea3742e041507acd564549617.tar.gz"
  version "1.46.0-mikluko.2"
  sha256 "dedc7f96c147ae9e45bd9113a62eca22d8fd0a01c9c98e745e67153a926bef3c"
  license "Apache-2.0"
  head "https://github.com/mikluko/goose.git", branch: "mikluko/osc8-hyperlinks"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "protobuf" => :build # for lance-encoding
  depends_on "rust" => :build

  uses_from_macos "llvm" => :build # for libclang

  conflicts_with "goose", because: "both install `goose` binaries"

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/goose-cli")

    generate_completions_from_executable(bin/"goose", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    crate_version = version.to_s.split("-").first
    assert_match crate_version, shell_output("#{bin}/goose --version")
    output = shell_output("#{bin}/goose info")
    assert_match "Paths:", output
    assert_match "Config dir:", output
    assert_match "Sessions DB (sqlite):", output
  end
end
