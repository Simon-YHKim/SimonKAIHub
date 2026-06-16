---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:07:51 KST
topic: 2ndB OCR LLM image policy parity guard
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@8965d46`
- Commit: `a63cd57 test(capture): guard OCR LLM image policy parity`
- Delta after commit: 24 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Now reads `src/lib/llm/gemini.ts`.
  - Asserts OCR's `MAX_OCR_IMAGE_BASE64_BYTES` matches `callGemini()`'s `MAX_INLINE_IMAGE_BASE64_LEN`.
  - Asserts OCR's MIME allowlist matches `ALLOWED_INLINE_IMAGE_MIME`.
  - Watches for wrapper-side base64 syntax validation, 12-byte signature sniffing, MIME compatibility, and the `llm_image_invalid_data` marker.

## Why

The OCR client guard, Gemini proxy guard, and `callGemini()` inline-image preflight all protect the same payload boundary. Proxy parity was already watched; this adds the missing OCR-to-wrapper parity guard so future changes do not create a late rejection or an unvalidated image type split.

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

- Test-only app change.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
