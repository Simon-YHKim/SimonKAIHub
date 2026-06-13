---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:04:01 KST
topic: 2ndB OCR crisis-result routing
---

## Summary

Continued the 2ndB multimodal/OCR safety pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@8965d46`
- Commit: `3ad7910 fix(capture): route crisis OCR results`
- Delta after commit: 23 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Added `IMAGE_OCR_CRISIS_RESULT_ERROR`.
  - If `callGemini()` returns `safety.zone === "red"` for OCR, `ocrImageAsset()` throws the sentinel instead of returning the swapped crisis template as extracted text.
- `src/app/capture.tsx`
  - Catches the sentinel in OCR extraction and opens the existing `CrisisRouter`.
  - Preserves locale/minor routing: KO minor -> `KR_1388`, KO adult -> `KR_109`, otherwise `GLOBAL_988`.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Added regression coverage for red-zone OCR output and sentinel helper behavior.
- `scripts/check-constraints.ts`
  - Added `CaptureOcrCrisisRouting` static gate.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (31 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:constraints`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

## Notes

- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
