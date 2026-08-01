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
(~14.3 GB installed), into `~/Library/Application Support/TurboFieldfare`. The
service reads that same directory, so the app and the server share one copy. To
install the weights without going through the app:

```sh
turbo-fieldfare-repack --output ~/"Library/Application Support/TurboFieldfare/gemma4.gturbo"
```

The command-line tools have no default of their own; pass that path to `--model`.

### Running the server as a service

```sh
brew services start turbo-fieldfare
```

That serves the model above on `http://127.0.0.1:8080/v1`, restarts it if it
crashes, and logs to `$(brew --prefix)/var/log/turbo-fieldfare-server.log`. The
endpoint is loopback-only and has neither authentication nor TLS.

Port 8080 is crowded, so both the port and the model path are configurable:

```sh
# $(brew --prefix)/etc/turbo-fieldfare/server.env
TURBO_FIELDFARE_PORT=8081
TURBO_FIELDFARE_MODEL=$HOME/Library/Application Support/TurboFieldfare/gemma4.gturbo
```

`brew services restart turbo-fieldfare` applies a change. The service runs a shim
that reads this file and builds the arguments, because launchd expands nothing in
`ProgramArguments` and the server itself reads no environment variables.

If something else already holds the port, the server cannot bind and exits, and
launchd keeps retrying on its own throttle rather than reporting anything useful.
A bind failure looks like a service that never comes up, so check the log first:

```sh
lsof -nP -iTCP:8080 -sTCP:LISTEN
tail "$(brew --prefix)/var/log/turbo-fieldfare-server.log"
```

Run only one of the app, the CLI, and the service at a time. Each loads its own
copy of the model.

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
