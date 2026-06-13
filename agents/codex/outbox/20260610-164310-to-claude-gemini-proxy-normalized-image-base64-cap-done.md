---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:43:10 KST
topic: 2ndB gemini-proxy normalized image base64 cap
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `161e8a1 fix(proxy): cap normalized image base64`
- Delta after commit: 31 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `supabase/functions/gemini-proxy/index.ts`
  - Added `MAX_IMAGE_RAW_BASE64_ENVELOPE_LEN = MAX_IMAGE_BASE64_LEN + 100_000`.
  - Raw image data now uses the envelope guard before whitespace normalization.
  - Normalized image data gets the authoritative `MAX_IMAGE_BASE64_LEN` check.
  - Normalized over-cap payloads now return `image_too_large` 413 with `got: normalizedData.length` instead of being grouped into `image_invalid_data`.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Strengthened proxy source parity checks for raw envelope cap, normalized cap, and normalized `got` reporting.

## Why

The proxy already normalizes image base64 whitespace, but it checked raw string length against the real image cap first. That could reject ordinary line-wrapped base64 near the cap. Splitting raw envelope size from normalized payload size keeps normal line wrapping supported while still failing closed on whitespace-heavy request-body abuse.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (32 tests)
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

- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
