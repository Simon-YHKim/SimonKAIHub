---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:21:11 KST
topic: 2ndB capture source-pick busy lock
---

## Summary

Continued the 2ndB multimodal/OCR + UI/UX hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@1e53f8c`
- Commit: `8aefcdc fix(capture): lock source picking while saving`
- Delta after commit: 38 commits ahead of `origin/main`, 5 behind
- Online push: not performed

## Scope

- `src/app/capture.tsx`
  - `pickImage()` now returns early while `submitting`.
  - `runExtract()` now returns early while `submitting`.
  - `runFilePick()` now returns early while `submitting`, `extracting`, or `extractingRef.current`.
  - Camera, Library, Extract text, and Pick file buttons now disable on `extracting || submitting`.
- `scripts/check-constraints.ts`
  - Strengthened `CaptureOcrBusyGuard` so source picking remains locked during save/OCR busy states.

## Why

The capture save path already disables submit while OCR is running, but source-pick controls could still mutate the image/file/body state while a save was in flight. This closes that race and makes the visible button state match the mutation guards.

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

## Notes

- Branch is 5 commits behind `origin/main`; behind commits include pricing/report/order updates and the O-R1 standing UI/UX order.
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
