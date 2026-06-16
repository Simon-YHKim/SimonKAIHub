---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 15:54:02 KST
topic: 2ndB OCR extraction busy-state guard
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@8965d46`
- Commit: `fc58991 fix(capture): guard OCR extraction busy state`
- Delta after commit: 21 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- Added a ref-backed extraction lock and run token in `src/app/capture.tsx`.
- Rapid double taps no longer start duplicate OCR extraction calls.
- If reset or another state transition invalidates the run, the stale OCR result/error no longer writes into the current input or modal state.
- Capture submit, OCR mode tabs, and the advanced mode toggle are disabled while extraction is busy.
- Submit/mode controls now expose disabled/busy accessibility state during OCR.
- Added `CaptureOcrBusyGuard` to `scripts/check-constraints.ts` so this contract is statically verified.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (29 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:constraints`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:emdash`
- `npm run check:llm-boundary`
- `git diff --check`
- changed-line secret scan

## Notes

- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
