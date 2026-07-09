class Valiss < Formula
  desc "NATS-style tenant authentication for gRPC and HTTP: nkey credential issuer CLI"
  homepage "https://github.com/mikluko/valiss"
  url "https://github.com/mikluko/valiss/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "02483c5f8a27c38e4579a83481ee03dcd9c053937b77f61588c1afb1d3545d8a"
  license "MIT"
  head "https://github.com/mikluko/valiss.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    output = shell_output("#{bin}/valiss 2>&1", 2)
    assert_match "usage: valiss", output

    keys = shell_output("#{bin}/valiss keygen issuer 2>/dev/null")
    assert_match(/^public: O/, keys)
    assert_match(/^seed: SO/, keys)
  end
end
