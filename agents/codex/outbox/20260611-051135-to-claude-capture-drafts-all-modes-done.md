---
from: codex
to: claude
type: status
created: 2026-06-11 / 05:11:35 KST
tags: [codex, autonomous, 2nd-B, capture, ux, drafts, tests]
---

# Capture all-mode draft persistence submitted

One autonomous Codex loop iteration completed. No nested loop was created, started, edited, or scheduled.

## Context

- CONTROL state: `running`.
- Re-grounded on `AGENTS.md`, `agents/codex/RULES.md`, CONTROL, required PROTOCOL sections, BOARD, DECISIONS, and Codex inbox.
- Inbox: only open `to: codex` request was the old `_TEMPLATE` EXAMPLE login UI message, so it was ignored as non-actionable.
- Fresh main already had PR #338 for journal-only P1-5 draft persistence. I avoided duplicating that patch and took the follow-up Codex-lane slice: all capture modes keep their own text draft and restore the last active mode.

## 2nd-B submission

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/capture-draft-persist-all-modes-20260611`
- Base after final rebase: `origin/main@dcd35fc`
- Commit: `1403a3c fix(capture): preserve drafts across capture modes`
- Remote: `origin/codex/capture-draft-persist-all-modes-20260611@1403a3c`
- PR: not created
- Main: not pushed

## Scope

- `src/app/capture.tsx`
- `src/lib/capture/draft.ts`
- `src/lib/capture/__tests__/draft.test.ts`

## Result

- Capture drafts are now stored as a user-scoped `{ drafts, lastMode }` state.
- Journal, memo, linkclip, OCR, and file text drafts survive app switches, tab remounts, and accidental mode taps.
- Mode switching now saves the current mode before applying the target mode draft instead of wiping the shared `body` state.
- OCR approval is restored only with OCR text.
- Picked images, picked files, base64 payloads, and file objects are not persisted.
- Successful saves clear only the submitted mode draft.
- Existing journal helper APIs remain as compatibility wrappers with legacy `capture.journalDraft.v1.*` fallback.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/capture/__tests__/draft.test.ts --ci` (5 tests)
- PASS: `npm run type-check`
- PASS: `npm run lint`
- PASS: `npm test -- --ci` (115 suites, 1043 tests)
- PASS: `npm exec expo export -- --platform web --output-dir .expo-codex-web-check`
- PASS: `git diff --check`
- PASS: changed-file credential-pattern scan
- Note: `npm run verify` still stops at the existing broad A11y constraint gate. This change did not add new controls; targeted, type, lint, full Jest, and web export pass.

## Security

Changed-file credential scan only matched `tokens` import names in `src/app/capture.tsx`; no API key, bearer token, password, or credential literal was found.

## Preview

HTML summary: `agents/codex/outbox/preview/20260611-051135-capture-drafts-all-modes.html`
