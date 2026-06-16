---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 18:03:43 KST
topic: 2ndB unsupported image signature OCR classification
---

## Summary

[2026-06-10 / 18:03:43 KST]

Continued the 2ndB multimodal/OCR payload hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@5d7facb`
- Commit: `3f118d7 fix(ocr): classify unsupported image signatures`
- Delta after final check: 44 commits ahead of `origin/main`, 13 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR payload validation now detects known unsupported image signatures after supported-image sniffing fails.
  - GIF, BMP, TIFF, and AVIF/AVIS are classified as `image_ocr_unsupported_type` instead of generic invalid data when MIME is missing or generic.
- `src/lib/llm/gemini.ts`
  - Direct/Vertex inline image preflight mirrors the same unsupported-signature classification before SDK calls.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy mirrors the same classifier and returns `image_mime_not_allowed` with the detected unsupported MIME.
- Tests:
  - Added capture OCR coverage for generic data URL GIF and raw/generic AVIF payloads.
  - Added direct/Vertex coverage for generic GIF and raw AVIF payloads.
  - Strengthened parity assertions so the proxy and wrapper keep the unsupported-signature path.

## Why

If picker/proxy input omits MIME or uses `application/octet-stream`, an unsupported but recognizable image file used to collapse into the same path as corrupt random bytes. That made UI feedback less precise and made the Edge boundary less explicit. This patch keeps the supported allowlist unchanged, but makes known unsupported image formats fail through the existing unsupported-image path.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (39 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (15 tests; expected audit-failure warning remains from an existing test)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

Post-commit PASS:

- `git diff --check HEAD~1..HEAD`
- changed-line secret scan for `HEAD~1..HEAD`

Not run:

- `deno check supabase/functions/gemini-proxy/index.ts`: Deno CLI is not installed in this environment.

## Notes

- Branch is 13 commits behind `origin/main`; behind commits are O-R1 cycle UI/docs updates through PR #318 (`5d7facb`).
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
