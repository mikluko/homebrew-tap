# mikluko/homebrew-tap

Homebrew formulae for my projects and for a few upstream ones with no tap.

## turbo-fieldfare

**Gemma 4 26B-A4B inference in about 2 GB of RAM on Apple Silicon**, including
8 GB Macs. Upstream:
[drumih/turbo-fieldfare](https://github.com/drumih/turbo-fieldfare).

```sh
brew install mikluko/tap/turbo-fieldfare
open /opt/homebrew/opt/turbo-fieldfare/TurboFieldfare.app
```

Needs macOS 26 on Apple Silicon. Builds from source; Command Line Tools are
enough. Installs the Mac app plus three commands:

| Command | Purpose |
| --- | --- |
| `turbo-fieldfare` | Instruction chat and raw completion |
| `turbo-fieldfare-server` | Loopback OpenAI-compatible Chat Completions server |
| `turbo-fieldfare-repack` | Streaming model installer and install verifier |

For Finder and Spotlight:

```sh
ln -sfn /opt/homebrew/opt/turbo-fieldfare/TurboFieldfare.app /Applications/TurboFieldfare.app
```

Weights are not included (~14.3 GB). The app installs them on first run, into
`~/Library/Application Support/TurboFieldfare`; the service reads the same
directory. Without the app:

```sh
turbo-fieldfare-repack --output ~/"Library/Application Support/TurboFieldfare/gemma4.gturbo"
```

The command-line tools have no default; pass that path to `--model`.

The app bundle is unsigned.

### Running the server as a service

```sh
brew services start turbo-fieldfare
```

Serves `http://127.0.0.1:8080/v1`, loopback only, no authentication or TLS. Logs
to `$(brew --prefix)/var/log/turbo-fieldfare-server.log`.

Port and model path come from `$(brew --prefix)/etc/turbo-fieldfare/server.env`;
`brew services restart turbo-fieldfare` applies changes.

```sh
TURBO_FIELDFARE_PORT=8081
TURBO_FIELDFARE_MODEL=$HOME/Library/Application Support/TurboFieldfare/gemma4.gturbo
```

A taken port shows up as a service that never starts, with the reason only in
the log. Run one of the app, the CLI, and the service at a time.

## hledger@1.99

The hledger 1.99.x pre-release series, the run-up to 2.0. Upstream:
[simonmichael/hledger](https://github.com/simonmichael/hledger).

```sh
brew install mikluko/tap/hledger@1.99
```

Keg-only, so it does not displace `hledger` from homebrew-core. Builds
`hledger`, `hledger-ui`, and `hledger-web` from source with the GHC the
release's `stack.yaml` pins (9.14).

```sh
export PATH="$(brew --prefix hledger@1.99)/bin:$PATH"
```

Or `brew link --overwrite hledger@1.99` to take over the stable one;
`brew unlink hledger@1.99 && brew link hledger` reverts.

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
packaging problems here, software bugs upstream.
