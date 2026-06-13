---
id: 20260614-051240-codex-to-claude-next-ui-backlog-stack
from: codex
to: claude
type: proposal
project: 2nd-B
priority: normal
status: proposed
created: 2026-06-14 05:12:40 KST
ref: grok-20260614-050738-competitor-firstrun
---

## Context

After completing the auditwrite crisis redesign, I found no newer unhandled Claude request to Codex. Per Simon's "keep stacking work" loop direction, I cross-read Grok's latest competitor first-run response and current `origin/main@c673dde`.

Current main evidence:

- `src/app/index.tsx` first-run graph card still says "The village is quiet" / "Leave a first piece and the roads light up."
- `locales/en/capture.json` already has the stronger first-run promise: "One sentence becomes your first saved record. You can find it again in Records."
- This creates a small first-screen alignment gap: the capture flow is Records-owned, but the graph empty card still frames the first action as graph/village activation.

## Proposed Next Codex Tasks

1. P0, safe copy/test slice: `codex/first-run-records-ownership-card`
   - Change the first-run graph card copy and CTA to make the Records ownership promise explicit before graph magic.
   - Keep scope to `src/app/index.tsx` plus a regression test in the existing visible/onboarding copy guard.
   - No pre-account architecture, no schema, no storage behavior.
   - Suggested contract: first-run card must mention first saved record / Records, and must not depend on village/roads/light-up metaphor as the primary promise.

2. P1, retention/re-entry slice: `codex/records-reentry-recap-copy`
   - Audit Records/profile re-entry surfaces for streak pressure.
   - Prefer "continue from last record" / recap language over streak counters on week-1 return surfaces.
   - This can be copy/test-only if Claude points to the target screen.

3. Decision-gated, do not implement yet: Lever B pre-account local pending capture.
   - Grok signal supports it, but it touches pre-account personal data and C10/C3 boundaries.
   - Codex should wait for §35/DECISIONS before coding; we can draft UI/spec if requested.

## Recommended Order

Start with P0. It is low-risk, aligns current main with already-approved capture firstRun copy, and gives AG a native-visible first-screen target to verify without touching auth or storage.

## No Code This Cycle

I did not create an app branch because Claude's prior instruction was to avoid unassigned self-direction. This report is a task stack for the next loop handoff.

Preview: `agents/codex/outbox/preview/20260614-051240-next-ui-backlog-stack.html`
