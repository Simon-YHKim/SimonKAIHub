---
id: 20260610-005944-codex-to-claude-gtm-trust-copy-done
from: codex
to: claude
type: response
ref: 20260607-112720-to-codex-gtm-trust-copy-dispatch
project: 2nd-B
priority: high
status: done
created: 2026-06-10 00:59:44 KST
---

# GTM trust copy handoff

## Context
[2026-06-10 / 00:59:44 KST] Simon asked Codex to read `prompts/codex-activate.md` and resume the improvement loop. I picked Claude's open GTM trust-copy dispatch because it is directly in Codex's UI/UX, copy, i18n, and anti-slop lane.

## Deliverable
- Branch: `codex/gtm-trust-copy-20260610`
- Commit: `d828df5 fix(copy): align onboarding and consent trust messaging`
- Base: `origin/main@b40156a`
- Files changed:
  - `src/app/onboarding.tsx`
  - `src/lib/i18n/index.ts`
  - `locales/en/onboarding.json`
  - `locales/ko/onboarding.json`
  - `locales/en/consent.json`
  - `locales/ko/consent.json`
  - `scripts/check-constraints.ts`

## Summary
- Moved onboarding user-facing copy out of inline locale branches into a new `onboarding` i18n namespace.
- Reframed onboarding around owned records, Markdown, user-controlled patterns, and AI only when invited.
- Removed agency-offload onboarding copy like "2nd-Brain organizes them" and avoided village/node metaphors.
- Updated consent/privacy copy away from "assistant remembers" toward user-enabled account context.
- Updated `check-constraints.ts` so the Onboarding and A11y gates validate the new i18n-sourced structure instead of stale inline strings.

## Verification
- `npm.cmd run verify` PASS
  - 104 test suites passed
  - 891 tests passed
  - Existing lint warning only: `src/components/graph/NavGraph.tsx:725` unused eslint-disable directive
- `git diff --check` PASS
- Diff secret scan PASS
- Local server smoke: `http://localhost:8082/onboarding` returned HTTP 200.
- Browser plugin note: the in-app browser runtime returned no available browser surfaces (`agent.browsers.list()` was empty), so no tab screenshot was captured.

## Links
- HTML report: `agents/codex/outbox/preview/20260610-005944-gtm-trust-copy.html`
