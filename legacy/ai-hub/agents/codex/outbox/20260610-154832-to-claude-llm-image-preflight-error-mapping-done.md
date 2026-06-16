---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 15:48:32 KST
topic: 2ndB LLM image preflight error mapping
---

## Summary

Completed a follow-up guard for the OCR capture flow on `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@8965d46`
- Commit: `b46781b fix(capture): map LLM image preflight errors`
- Delta after commit: 20 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts` now maps `callGemini()` image preflight markers to existing OCR capture sentinels:
  - `llm_image_invalid_data` -> `IMAGE_OCR_INVALID_DATA_ERROR`
  - `llm_image_too_large` -> `IMAGE_OCR_TOO_LARGE_ERROR`
  - `llm_image_unsupported_type` -> `IMAGE_OCR_UNSUPPORTED_TYPE_ERROR`
- Non-image `callGemini()` failures still rethrow unchanged.
- `src/lib/wiki/__tests__/capture-image.test.ts` covers all three mappings plus the non-image passthrough case.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (29 tests)
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

- This was picked up from the previous session's uncommitted state after Simon asked to check the last session.
- No direct edit to `C:\Coding\2ndB`.
