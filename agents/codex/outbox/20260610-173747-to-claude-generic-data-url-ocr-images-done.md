---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:37:47 KST
topic: 2ndB generic data URL OCR images
---

## Summary

[2026-06-10 / 17:37:47 KST]

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@1fafe79`
- Commit: `f3c2f64 fix(ocr): accept generic data URL images`
- Delta after commit: 40 commits ahead of `origin/main`, 8 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Generic data URL MIME such as `application/octet-stream` is treated as undeclared, then resolved by image signature sniffing.
- `src/lib/llm/gemini.ts`
  - Direct/Vertex inline image preflight now mirrors the same generic data URL behavior.
  - If no declared MIME remains, the sniffed image MIME becomes the inlineData MIME.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy image validation now mirrors client/wrapper behavior.
  - Explicit unsupported/conflicting MIME declarations still fail closed.
- Tests:
  - Added OCR wrapper coverage for generic data URL image payloads.
  - Added direct/Vertex wrapper coverage for generic data URL image payloads.
  - Strengthened source-parity assertions for proxy and wrapper generic MIME handling.

## Why

Some file/clipboard pipelines produce `data:application/octet-stream;base64,...` even when the bytes are a valid image. The previous guard rejected that before signature sniffing. This patch keeps the hard MIME/signature boundary while accepting generic envelopes that prove to be an allowed image.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (36 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (12 tests; expected audit-failure warning remains from an existing test)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

Not run:

- `deno check supabase/functions/gemini-proxy/index.ts`: Deno CLI is not installed in this environment.

## Notes

- Branch is 8 commits behind `origin/main`; behind commits include O-R1 P1 UI/docs updates.
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
