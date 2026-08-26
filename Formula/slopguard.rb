class Slopguard < Formula
  desc "Claude Code hook objecting to comments whose claim belongs elsewhere"
  homepage "https://github.com/mikluko/slopguard"
  url "https://github.com/mikluko/slopguard/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "c19a6ab4bfa7dfba427bb6aec08e83727c9af79a02f53bbf7e13220bf52f90b9"
  # The source is MIT and the binary embeds all-MiniLM-L6-v2, which is
  # Apache-2.0. Both apply, to different parts of the same artifact, so this is
  # all_of and not any_of: any_of renders as SPDX OR, which would say a
  # recipient may take the whole thing under either.
  license all_of: ["MIT", "Apache-2.0"]
  head "https://github.com/mikluko/slopguard.git", branch: "main"

  depends_on "go" => :build
  depends_on "onnxruntime"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "."
    # The embedded model is Apache-2.0 and its licence has to travel with the
    # artifact. From a source build the tarball carries it; from a bottle
    # nothing would, so install it rather than relying on how this was built.
    doc.install "internal/model/assets/LICENSE.apache-2.0",
                "internal/model/assets/PROVENANCE"
  end

  test do
    (testpath/"double.go").write <<~GO
      package p

      func double(v int) int {
      \t// close the connection
      \tconn.Close()
      \treturn v * 2
      }
    GO

    # The sweep mode judges files named as arguments, which is the same
    # judgment the hook makes and needs no payload to exercise.
    assert_match "restates", shell_output("#{bin}/slopguard #{testpath}/double.go")

    # This one needs the model: its words are nowhere in the line below it, so
    # the structural rules cannot reach it and a build that failed to find
    # ONNX Runtime fails here rather than passing quietly on the phrase list.
    (testpath/"twice.go").write <<~GO
      package p

      func double(v int) int {
      \t// multiply it by two
      \treturn v * 2
      }
    GO
    assert_match "restates", shell_output("#{bin}/slopguard #{testpath}/twice.go")

    (testpath/"clean.go").write <<~GO
      package p

      // double returns v twice over.
      func double(v int) int { return v * 2 }
    GO
    assert_empty shell_output("#{bin}/slopguard #{testpath}/clean.go")

    payload = {
      "tool_name"  => "Write",
      "cwd"        => testpath.to_s,
      "tool_input" => {
        "file_path" => "#{testpath}/clean.go",
        "content"   => (testpath/"clean.go").read,
      },
    }.to_json
    assert_empty pipe_output(bin/"slopguard", payload, 0)
  end
end
