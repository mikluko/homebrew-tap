# mikluko/homebrew-tap

Homebrew formulae for my own projects and for a few upstream ones that ship no
tap of their own.

## turbo-fieldfare

**Gemma 4 26B-A4B inference in about 2 GB of RAM, on any Apple Silicon Mac
including the 8 GB ones.** A Swift and Metal runtime that keeps the shared model
core resident and streams only the experts each token needs from SSD, instead of
loading the full 14.3 GB checkpoint into memory. Upstream:
[drumih/turbo-fieldfare](https://github.com/drumih/turbo-fieldfare).

```sh
brew install mikluko/tap/turbo-fieldfare
open /opt/homebrew/opt/turbo-fieldfare/TurboFieldfare.app
```

That installs the Mac app alongside three commands:

| Command | Purpose |
| --- | --- |
| `turbo-fieldfare` | Instruction chat and raw completion |
| `turbo-fieldfare-server` | Loopback OpenAI-compatible Chat Completions server |
| `turbo-fieldfare-repack` | Streaming model installer and install verifier |

Requires an Apple Silicon Mac on macOS 26 with Xcode 26, and builds from source.

The app lives in the keg rather than `/Applications`, since a formula only
writes inside its own prefix. To reach it from Finder and Spotlight:

```sh
ln -sfn /opt/homebrew/opt/turbo-fieldfare/TurboFieldfare.app /Applications/TurboFieldfare.app
```

Model weights are not included. The app downloads and repacks them on first run
(~14.3 GB installed), or `turbo-fieldfare-repack --output ~/gemma4.gturbo` does
the same from a terminal.

The app bundle is unsigned: SwiftPM resolves its resource bundles against the
`.app` root, which `codesign` rejects as unsealed content. A locally built app
carries no quarantine flag, so Gatekeeper never inspects it.

## Other formulae

```sh
brew install mikluko/tap/<formula>
```

| Formula | Description | Upstream |
| --- | --- | --- |
| `claudectx` | Launch Claude Code with provider contexts, kubeconfig-style | [mikluko/claudectx](https://github.com/mikluko/claudectx) |
| `mcp-proxy` | MCP proxy connecting stdio/HTTP clients to remote servers, with OAuth | [mikluko/mcp-proxy](https://github.com/mikluko/mcp-proxy) |
| `hledger-fmt` | hledger add-on: format-preserving journal formatter | [mikluko/hledger-fmt](https://github.com/mikluko/hledger-fmt) |
| `hledger-close-cta` | hledger add-on: period-end closing with currency translation adjustment | [mikluko/hledger-close-cta](https://github.com/mikluko/hledger-close-cta) |
| `claude-agent-acp` | ACP adapter for Claude Code, powered by the Claude Agent SDK | [agentclientprotocol/claude-agent-acp](https://github.com/agentclientprotocol/claude-agent-acp) |

Formulae for other people's projects are unofficial and unaffiliated. Report
packaging problems here; report bugs in the software upstream.
