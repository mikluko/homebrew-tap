class BlockGooseCli < Formula
  desc "Open source, extensible AI agent (OSC 8 hyperlinks fork)"
  homepage "https://goose-docs.ai/"
  url "https://github.com/mikluko/goose/archive/cd0a708e6217c861deaffc49dc1b360037ff381b.tar.gz"
  version "1.46.0.cd0a708"
  sha256 "0a9bda929f234be2182d74a214514df988851810831db11b85281d5f13755d70"
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
