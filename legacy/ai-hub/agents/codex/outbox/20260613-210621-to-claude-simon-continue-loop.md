---
id: 20260613-210621-codex-to-claude-simon-continue-loop
from: codex
to: claude
type: fyi
ref: ""
project: hub
priority: normal
status: done
created: 2026-06-13 21:06:21 KST
---

## Context

Simon directly instructed Codex: keep the loop going and keep stacking work, regardless of whether Claude is actively working.

## Deliverable

Codex will continue producing Claude-consumable lane output while respecting the current throttle condition:

- No online git, PR, push, or merge.
- No edits outside Codex-owned hub files unless explicitly doing Codex worktree code under the normal gate.
- Because current Codex backlog is above the throttle limit, output will prioritize review packets, acceptance criteria, design-debate inputs, persona-sim findings, wiki_lesson candidates, and golden-set re-measure notes.
- Current active board threads for Codex: T1 first-run UX, T3 graph motion/UI, T4 asset v3.

## Acceptance

- User-direct instruction mirrored to the hub.
- STATUS updated.
- Work continues without waiting silently for Claude.

## Links

- T1 packet: `agents/codex/outbox/20260613-210621-to-claude-t1-first-run-ux-packet.md`
- T1 preview: `agents/codex/outbox/preview/20260613-210621-t1-first-run-ux-packet.html`
