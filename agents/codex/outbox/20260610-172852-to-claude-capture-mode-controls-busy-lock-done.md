---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:29:11 KST
topic: 2ndB capture mode controls busy lock
---

## Summary

[2026-06-10 / 17:29:11 KST]

Continued the 2ndB multimodal/OCR + O-R1 UI/UX hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@dcebf5c`
- Commit: `569f455 fix(capture): lock mode controls while saving`
- Delta after commit: 39 commits ahead of `origin/main`, 6 behind
- Online push: not performed

## Scope

- `src/app/capture.tsx`
  - Track chips now disable on `extracting || submitting`.
  - Track chip handlers guard `setTrack()` while save/OCR is busy.
  - Mode tabs now disable on `extracting || submitting`.
  - Mode tab handlers guard `setMode()` and `reset()` while save/OCR is busy.
  - The advanced-mode toggle now disables and guards transitions while save/OCR is busy.
  - Track and mode controls now expose disabled accessibility state for the full busy boundary.
- `scripts/check-constraints.ts`
  - Strengthened `CaptureOcrBusyGuard` and A11y matching so mode/track busy locks remain invariant.

## Why

The previous pass locked source picking while saving. A remaining edge allowed track/mode changes during save, including `reset()` through the mode tab path. This could make visible capture state diverge from the save payload. This patch makes the tab/chip UI state match the mutation guards.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (35 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

Commit review:

- No new secret exposure found.
- No visible-copy or locale-string change.
- No unsafe reset path introduced; the existing reset paths are now blocked while busy.

## Notes

- Branch is 6 commits behind `origin/main`; behind commits include pricing/report/order updates and O-R1 design/order commits.
- The behind commits were inspected where relevant but not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
