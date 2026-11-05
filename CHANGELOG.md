# CHANGELOG — buzz-opencode-adapter

## 2026-11-05 — Align with current stack; drop stale Dokploy MCP path

- `BUZZ_ACP_MCP_COMMAND=/usr/bin/dokploy-mcp` removed. The binary was retired
  on 2026-10-24; OpenCode's global `mcp.dokploy`
  (`npx @vibetools/dokploy-mcp`, v4.0.0) now supplies it to every session.
- Added `BUZZ_OUTPUT_FORMAT=agent` so agent-side `buzz` reads are token-lean
  (new CLI from sprig `0.1.0+git.920b1e6`).
- Documented the always-on lifetime policy (`BUZZ_ACP_EXIT_AFTER_INACTIVITY=0`)
  and the kind:10100 profile env (`PUBLISH_PROFILE`, `DISPLAY_NAME`) that the
  wrapper has set since 2026-11-04.
- OpenCode moved to 2.0.31; it still reports ACP v1 and has no `systemPrompt`
  on `session/new`, so the `instructions` handoff is unchanged.
- Harness image now rebases the two open patches onto main `920b1e64`; the
  adapter's local binary was rebuilt from that tree.

## 2026-10-28 — Initial adapter

- Moved Buzz `<base>` preamble out of buzz-acp per-turn injection into scoped
  AGENTS.md; set `BUZZ_ACP_NO_BASE_PROMPT=true`.
- Scoped to `/home/admin/buzz` via wrapper `cd`; core memory injection left on.
- Added `BUZZ_ACP_CONTEXT_MESSAGE_LIMIT=0` (thread/conversation fetch redundant
  with OpenCode session history).
- Added persona materialization: `opencode.json` `instructions` -> `PERSONA.md`,
  written from `BUZZ_ACP_SYSTEM_PROMPT`/`BUZZ_ACP_TEAM_INSTRUCTIONS` by
  `scripts/materialize-persona.sh`.
- Multi-agent review: goose path untouched; context-limit change confirmed safe
  against `pool.rs` (`context_message_limit` gates only `fetch_conversation_context`,
  event block + reply anchor always render).
