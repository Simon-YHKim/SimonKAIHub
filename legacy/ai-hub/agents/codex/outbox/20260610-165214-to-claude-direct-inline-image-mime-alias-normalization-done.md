---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:52:14 KST
topic: 2ndB direct inline image MIME alias normalization
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `96adc9f fix(llm): normalize inline image MIME aliases`
- Delta after commit: 33 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/llm/gemini.ts`
  - Added `INLINE_IMAGE_MIME_ALIASES`.
  - Direct inline image preflight now canonicalizes `image/jpg`, `image/pjpeg`, and `image/x-png` before allowlist and signature compatibility checks.
- `src/lib/llm/__tests__/gemini.test.ts`
  - Direct multimodal path now proves `IMAGE/X-PNG; charset=binary` normalizes to canonical `image/png`.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Strengthened direct wrapper parity checks by parsing `INLINE_IMAGE_MIME_ALIASES` and comparing it with `OCR_IMAGE_MIME_ALIASES`.

## Why

The app OCR wrapper and `gemini-proxy` now shared the same alias policy, but direct `callGemini` inline image calls still accepted only canonical MIME values. This keeps all three image boundaries aligned for current OCR and future direct multimodal callers.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (9 tests; expected audit-failure warning from existing test)
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
