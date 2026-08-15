class BlockGooseCli < Formula
  desc "Open source, extensible AI agent (OSC 8 hyperlinks fork)"
  homepage "https://goose-docs.ai/"
  url "https://github.com/mikluko/goose/archive/ec23a8ca673c630b2e9cd9e345336d1669bcabf7.tar.gz"
  version "1.46.0-mikluko.4"
  sha256 "a9a36b909405c497d68d339ea94a0d6aec9c32935cd98b73ac9a774a0fc04a29"
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
