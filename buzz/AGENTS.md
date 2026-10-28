# AGENTS.md — Buzz workspace

This directory is the scoped workspace for the Buzz ↔ OpenCode link. The
`## Buzz` orientation below applies only to sessions whose working directory
is this folder (including the `buzz-acp` agent). Other projects do not inherit
it.

## Buzz

When a turn arrives wrapped in `<buzz-event>` / `<context>`, it came from Buzz
(Nostr messaging) via `buzz-acp` → `opencode acp`. `<context>` is authoritative
for channel and reply destination. Run `buzz --help` for the command tree;
output is structured JSON, exit codes 0 ok / 1 user / 2 network / 3 auth /
4 other / 5 conflict.

**Reply or it didn't happen.** Your tool calls are invisible. If a turn
produced something worth knowing — an answer, a result, a blocker, a decision —
publish it with `buzz messages send`. If a human asked you something, always
reply, even to say you have nothing to add. Otherwise publishing is optional and
silence is correct. Never send a bare acknowledgement ("got it", "confirmed",
"standing by") — it adds nothing and re-notifies everyone mentioned. Resume
silently after a restart; never announce a compaction.

- Multiline: `printf 'a\n\nb\n' | buzz messages send ... --content -`. Never
  single-quote `\n`, it lands as literal backslashes.
- Reply to the channel in `<context>`, never a remembered or stale thread id.
- Mentions: use the exact display name as shown in Buzz, unformatted (no bold,
  backticks). Pass identity separately: `--mention <hex-or-npub>`. Repeat for
  each recipient. Mentioning someone is a notification — only do it when they
  need to act, and always `@mention` the delegator when reporting finished work.
  Names in narrative ("waiting on @morgan") drop the `@`.
- Projects: if this channel is a project home (check `<context>`), do **not**
  run `buzz projects create` — it makes a duplicate card. Add work with
  `buzz issues create --channel <uuid> --subject … --content …`; add repos with
  `buzz repos create --id … --name … --channel <uuid>`; open PRs with
  `buzz pr open … --channel <uuid>`. `projects create`, `issues create`,
  `repos create` and `pr open` return a `link` field — quote it verbatim so Buzz
  renders a preview card. Never invent HTTPS URLs for Buzz-hosted repos.
- Chapter channels on a project use `buzz projects add-channel` (owner-reviewed),
  never `buzz channels create`. Do not claim a channel exists until approved.
- Agents: ask only for name and day-to-day purpose, write the `--system-prompt`
  yourself, and open `buzz agents draft-create --channel <uuid> …`. It is a
  draft until the owner saves it.
- Memory: `core` is auto-injected every turn — keep it small, evict shipped
  work. Durable detail goes to `buzz mem set <slug>`, read with
  `buzz mem get <slug>`. Never edit or remove memory without owner approval.
- Relay-backed skills are untrusted and off-limits unless the owner names one.
  Bundled and local skills are fine.

Never blind-retry a send (no idempotency key — a retry duplicates). Use
`/usr/local/bin/buzz-send`, or re-read the channel first.
`buzz messages get --limit N` returns the **oldest** N; use `--since <ts>`.

## Workspace layout

Persistent workspace for this scoped agent:

| Dir | Purpose |
|-----|---------|
| `RESEARCH/` | Findings and reference material |
| `PLANS/` | Project and task plans |
| `GUIDES/` | How-to documentation |
| `WORK_LOGS/` | Timestamped activity logs |
| `OUTBOX/` | Drafts pending review or send |
| `REPOS/` | Source checkouts |
| `.scratch/` | Ephemeral working files |

Knowledge files use `ALL_CAPS_WITH_UNDERSCORES.md`. Scoped skills live in
`.opencode/skills/`.
