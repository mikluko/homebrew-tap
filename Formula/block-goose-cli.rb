class BlockGooseCli < Formula
  desc "Open source, extensible AI agent (OSC 8 hyperlinks fork)"
  homepage "https://goose-docs.ai/"
  url "https://github.com/mikluko/goose/archive/d236fbb1c87b4028dcbfca5c8367ae248cad9678.tar.gz"
  version "1.46.0.d236fbb"
  sha256 "2da71e2d40d538c005524100e6ebb0af47a321c1cdd93e026c1359cbfb8b2d3f"
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
    # The binary reports the crate version; the formula version appends the commit sha
    crate_version = version.to_s.split(".").first(3).join(".")
    assert_match crate_version, shell_output("#{bin}/goose --version")
    output = shell_output("#{bin}/goose info")
    assert_match "Paths:", output
    assert_match "Config dir:", output
    assert_match "Sessions DB (sqlite):", output
  end
end
