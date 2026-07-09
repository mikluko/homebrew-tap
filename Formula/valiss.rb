class Valiss < Formula
  desc "NATS-style tenant authentication for gRPC and HTTP: nkey credential issuer CLI"
  homepage "https://github.com/mikluko/valiss"
  url "https://github.com/mikluko/valiss/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "eb59b28b62d121a3cd4e0f209ffdb2d45d48c8770f9e0c07d14e023420c4036c"
  license "MIT"
  head "https://github.com/mikluko/valiss.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
  end

  test do
    output = shell_output("#{bin}/valiss 2>&1", 2)
    assert_match "usage: valiss", output

    keys = shell_output("#{bin}/valiss keygen operator 2>/dev/null")
    assert_match(/^public: O/, keys)
    assert_match(/^seed: SO/, keys)
  end
end
