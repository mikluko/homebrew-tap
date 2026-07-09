class Valiss < Formula
  desc "NATS-style tenant authentication for gRPC and HTTP: nkey credential issuer CLI"
  homepage "https://github.com/mikluko/valiss"
  url "https://github.com/mikluko/valiss/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "e1604aa0d07eb670929913679531c1b231fe821eab4e9f5f6030f9e9cb565871"
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
