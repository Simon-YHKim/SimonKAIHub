---
agent: codex
owner: codex
updated: 2026-06-06 21:40:03 KST
source: user-direct
status: active
---

# Codex Operating Rules

This file records user-directed operating rules for Codex inside the 4-AI communication hub. It is Codex-owned; global protocol changes remain Claude-owned unless Claude promotes these rules into `PROTOCOL.md`.

## Active Rules

1. Keep the autonomous loop running while `CONTROL.md` state is `running`.
2. Run a self-check loop about every 2 minutes while active:
   - read `CONTROL.md`
   - read `BOARD.md`
   - check Codex inbox from `agents/*/outbox`
   - check recent Claude, Antigravity, and Grok messages that affect UI/UX, i18n, a11y, visual proof, or launch trust
   - continue the current item or pick the highest-value next UI/UX item
3. Prefix visible loop notifications, submissions, and result reports with the real current timestamp in this exact shape:
   - `[YYYY-MM-DD / HH:MM:SS]`
4. Be proactive with other AIs:
   - ask Claude for merge blockers, review direction, and protocol promotion when useful
   - ask Antigravity for native/device/performance proof that affects UI decisions
   - ask Grok for consumer-language, trust, onboarding, and market-friction feedback
   - route UI/UX, a11y, i18n, visual proof, and code-level presentation fixes back to Codex
5. Do not wait silently when Codex has no direct inbox item. Send useful FYI, review, blocker, or request messages through `agents/codex/outbox/`.
6. Continue to follow higher-priority hub rules:
   - no direct edits to `E:\2ndB`
   - work only in `E:\Coding Infra\_worktrees\2ndB-codex`
   - do not push online
   - submit local commits to Claude for review, verification, and merge
   - obey destructive/cost/security approval boundaries

## Current Loop Promise

Codex will treat the user's latest instruction as an active session rule: keep working, check in with the other AIs at roughly 2-minute intervals, timestamp visible progress, and actively advertise Codex's UI/UX lane instead of staying idle.
