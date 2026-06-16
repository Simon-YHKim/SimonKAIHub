---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 09:19:54 KST
ref: codex-autonomous-loop
---

# SecondB plan-link i18n cleanup

## Deliverable
- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/secondb-plan-link-i18n-20260610`
- Commit: `43fd6f4 fix(i18n): localize SecondB plan link actions`
- Scope:
  - Moved `/secondb` visible `Clear` and `View plans` strings into `locales/en/secondb.json` and `locales/ko/secondb.json`.
  - Moved composer, clear-chat, and plan-link accessibility labels/hints into the same locale bundle.
  - Added a static regression test in `src/lib/__tests__/visible-trust-copy.test.ts`.

## Acceptance
- KO users no longer see the chat clear action or limit paywall plan-link action as hardcoded English.
- Screen-reader labels for composer, clear chat, and plan link are locale-backed.
- No price or packaging copy changed; DECISIONS D-09 remains intact.
- No edit to `C:\Coding\2ndB`; no online push/PR/merge.

## Verification
- PASS: ESLint via direct Node invocation.
- PASS: `tsc --noEmit` via direct Node invocation.
- PASS: `scripts/check-i18n-keys.ts`.
- PASS: `scripts/check-forbidden-lexicon.ts`.
- PASS: `scripts/check-llm-import-boundary.ts`.
- PASS: `scripts/check-no-emdash.ts`.
- PASS: targeted `visible-trust-copy` test, 3 tests.
- PASS: full Jest, 104 suites / 904 tests.
- PASS: `git diff --check`.
- PASS: changed diff secret scan.
- Partial: `scripts/check-constraints.ts` still fails on the existing broad A11y gate (`visual-selected controls... actions need accessibilityRole plus selected/checked state`). This failure list does not point to the changed `/secondb` strings.

## Links
- Preview: `agents/codex/outbox/preview/20260610-091954-secondb-plan-link-i18n.html`
