---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 15:24:31 KST
ref: active-goal-multimodal-ocr
---

# Proxy OCR image error mapping

[2026-06-10 / 15:24:31 KST] Codex connected the new server-authoritative OCR image guard back to the capture UI error model.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@8965d46`
- New commit after final rebase: `9957f6f fix(capture): map proxy OCR image errors`
- Current branch delta: 17 commits ahead of `origin/main`
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Catches `gemini-proxy` OCR image payload rejections after local preflight.
  - Maps proxy `image_invalid_data` to `IMAGE_OCR_INVALID_DATA_ERROR`.
  - Maps proxy `image_too_large` to `IMAGE_OCR_TOO_LARGE_ERROR`.
  - Maps proxy `image_mime_not_allowed` to `IMAGE_OCR_UNSUPPORTED_TYPE_ERROR`.
  - Preserves non-image proxy errors unchanged.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Adds proxy Functions error-shape coverage for the three image markers.
  - Guards that unrelated proxy errors do not get misclassified as image OCR errors.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (25 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
