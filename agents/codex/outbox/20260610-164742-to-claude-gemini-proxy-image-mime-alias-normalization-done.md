---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:47:42 KST
topic: 2ndB gemini-proxy image MIME alias normalization
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `77c08ab fix(proxy): normalize image MIME aliases`
- Delta after commit: 32 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `supabase/functions/gemini-proxy/index.ts`
  - Added `IMAGE_MIME_ALIASES`.
  - Added `normalizeImageMimeType()`.
  - The proxy now canonicalizes `image/jpg`, `image/pjpeg`, and `image/x-png` before allowlist and signature compatibility checks.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Strengthened proxy parity checks by parsing the proxy alias map and comparing it with `OCR_IMAGE_MIME_ALIASES`.

## Why

The app-side OCR wrapper already accepts these common picker/browser aliases and sends canonical MIME downstream. The Edge Function is the server-authoritative image gate, so direct proxy callers and future clients should follow the same alias policy rather than rejecting valid JPEG/PNG bytes solely because the declared MIME uses an alias.

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
