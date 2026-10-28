# CHANGELOG — buzz-opencode-adapter

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
