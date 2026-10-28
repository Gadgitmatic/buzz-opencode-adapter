# buzz-opencode-adapter

Headless adapter that runs the Buzz ACP harness (`buzz-acp`) with OpenCode
(`opencode acp`) as the agent, scoped to a single working directory so Buzz
orientation, project instructions, and skills apply only to this agent and not
to web-UI sessions against other projects.

## Why this exists

`opencode acp` advertises ACP protocol v1 and its `newSession` handler reads
only `cwd`, `additionalDirectories`, and `mcpServers` — there is no
`systemPrompt` field, so `buzz-acp`'s `has_system_prompt_support()` returns
false for OpenCode and falls back to legacy user-message framing. That means
the compiled-in `<base>` preamble (~15 KB) and `<core-memory>` block ride in
the *first* user message of every new session.

This adapter moves the standing context into OpenCode's own system-prompt
channels (`AGENTS.md` + `opencode.json` `instructions`) and disables the
buzz-acp per-turn injection, so the per-turn user message shrinks to the
`<context>` + `<buzz-event>` envelope.

## Layout

```
wrapper/buzz-acp-wrapper.sh   # systemd ExecStart; loads secrets, sets env, cd's, execs buzz-acp
buzz/AGENTS.md                # hand-written Buzz orientation (stable)
buzz/opencode.json            # "instructions": ["./PERSONA.md"]
buzz/PERSONA.md               # generated from BUZZ_ACP_SYSTEM_PROMPT / TEAM_INSTRUCTIONS
buzz/scripts/materialize-persona.sh
buzz/.opencode/skills/        # scoped skills (progressive disclosure)
```

## Environment

Set by the wrapper (secrets come from 0600 files, not committed):

| Var | Value | Why |
|---|---|---|
| `BUZZ_ACP_NO_BASE_PROMPT` | `true` | base prompt lives in AGENTS.md/instructions |
| `BUZZ_ACP_CONTEXT_MESSAGE_LIMIT` | `0` | OpenCode keeps session history; thread fetch is redundant |
| `BUZZ_ACP_NO_MEMORY` | unset (default on) | core memory rides the agent key, not the disk |
| `BUZZ_ACP_AGENT_COMMAND` | `opencode` | |
| `BUZZ_ACP_AGENT_ARGS` | `acp` | |
| `BUZZ_ACP_RESPOND_TO` | `owner-only` | |
| `HOME` | `/home/admin` | global opencode config (MCP servers) still loads |
| cwd | `/home/admin/buzz` | project-local AGENTS.md + instructions + skills |

Persona handoff: a launcher sets `BUZZ_ACP_SYSTEM_PROMPT` and/or
`BUZZ_ACP_TEAM_INSTRUCTIONS` in `launch.policy_env`; `materialize-persona.sh`
writes them to `PERSONA.md` before `buzz-acp` starts, and `opencode.json`
pulls that file into the instruction layer. No AGENTS.md hand-editing needed.

## Install

```sh
sudo install -m 0755 wrapper/buzz-acp-wrapper.sh /usr/local/bin/buzz-acp-wrapper.sh
mkdir -p /home/admin/buzz
cp -r buzz/* /home/admin/buzz/
# wire your systemd unit's ExecStart to /usr/local/bin/buzz-acp-wrapper.sh
```

## Goose safety

This adapter is OpenCode-specific. Goose uses a different agent command and
its own path through `buzz-acp` (`_goose/unstable/session/system-prompt/set`,
set mode). Nothing here touches the `buzz-acp` binary or the goose path, so
goose is unaffected. Do not set `BUZZ_ACP_NO_BASE_PROMPT` for a goose agent —
goose needs the base prompt in its system prompt.

## Upstream status

`buzz-acp` squats on ACP v2 ahead of the upstream RFD (see
`crates/buzz-acp/src/acp.rs`). OpenCode reports v1, so system-prompt handoff
goes through `instructions` instead. The `codex/slim-agent-context` branch
slims the base prompt further but is unmerged and conflicts on merge; not
adopted here yet.
