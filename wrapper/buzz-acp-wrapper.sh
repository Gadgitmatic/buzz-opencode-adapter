#!/usr/bin/env bash
set -euo pipefail
# Load secrets from 0600 files into env (buzz-acp + opencode inherit these)
export BUZZ_RELAY_URL=wss://buzz.gadgitmatic.com
export BUZZ_PRIVATE_KEY="$(cat /home/admin/.config/opencode/secrets/buzz-private-key)"
export BUZZ_ACP_AGENT_COMMAND=opencode
export BUZZ_ACP_AGENT_ARGS=acp
export BUZZ_ACP_AGENT_OWNER=338813b3bd102b1bf3b25c939b3a4640db8cadeede869433d839886da0427535
export BUZZ_ACP_RESPOND_TO=owner-only
# Base prompt (Buzz orientation) is delivered by OpenCode's own system prompt via
# AGENTS.md + opencode.json `instructions`, not by buzz-acp. Keep base off so it
# doesn't also land in the first-turn user message.
export BUZZ_ACP_NO_BASE_PROMPT=true
# buzz-acp fetches up to N prior messages as <thread-context>/<conversation-context>
# on DM and threaded turns. OpenCode keeps the session history, so this is
# redundant; 0 disables the fetch and its per-turn injection.
export BUZZ_ACP_CONTEXT_MESSAGE_LIMIT=0
# Core memory (<core-memory>) STAYS injected by buzz-acp (default on) — it rides
# the agent key, not the disk, so it survives harness/container moves.
export BUZZ_ACP_HEARTBEAT_INTERVAL=0
# Deliberate always-on lifetime policy: 0 = never self-terminate. The unit keeps
# Restart=always, so a non-zero bound here would be resurrected on every idle
# exit. Change both together if you ever want a self-reaping server agent.
export BUZZ_ACP_EXIT_AFTER_INACTIVITY=0
# Self-publish kind:10100 so Desktop can discover this agent and authorise
# @mentions. Requires a buzz-acp build that carries PR #5691.
export BUZZ_ACP_PUBLISH_PROFILE=true
export BUZZ_ACP_DISPLAY_NAME=Gilfoyle
# The Dokploy MCP is provided by OpenCode's global config (`mcp.dokploy`,
# `npx @vibetools/dokploy-mcp`). The old harness-side command pointed at
# /usr/bin/dokploy-mcp, which no longer exists after the 2026-10-24 MCP
# consolidation. Rely on OpenCode's config instead of a second copy.
# export BUZZ_ACP_MCP_COMMAND=/usr/bin/dokploy-mcp
export DOKPLOY_URL="$(cat /home/admin/.config/opencode/secrets/dokploy-url)"
export DOKPLOY_API_KEY="$(cat /home/admin/.config/opencode/secrets/dokploy-key)"
# Token-lean reads for anything the agent runs through the CLI. Newer
# harnesses set this themselves; this keeps older builds aligned.
export BUZZ_OUTPUT_FORMAT=agent
# opencode acp needs the API key for opencode-go provider
export OPENCODE_API_KEY="$(grep '^OPENCODE_API_KEY=' /etc/opencode-web.env | cut -d= -f2-)"
export HOME=/home/admin
# Scope the Buzz ↔ OpenCode link to a single working directory so the project-
# local AGENTS.md, opencode.json `instructions`, and .opencode/skills/ there
# apply only to this agent (and not to web UI sessions against other projects).
cd /home/admin/buzz
# Materialize any handed-over persona into PERSONA.md (no-op when unset).
/home/admin/buzz/scripts/materialize-persona.sh /home/admin/buzz/PERSONA.md
exec /usr/local/bin/buzz-acp
