---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:11:02 KST
topic: 2ndB conflicting image MIME declaration rejection
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@c17f08b`
- Commit: `a50d908 fix(capture): reject conflicting image MIME declarations`
- Delta after commit: 36 commits ahead of `origin/main`, 2 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Data URL MIME and outer `image.mimeType` are now compared when both are allowed image MIME declarations.
  - Conflicting allowed declarations fail closed with `image_ocr_invalid_data`.
- `src/lib/llm/gemini.ts`
  - Direct inline image preflight now rejects conflicting data URL MIME and outer MIME before SDK calls.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy image validation now applies the same conflict guard.
- Tests
  - OCR wrapper regression: outer `image/jpeg` plus `data:image/png;base64,...` is rejected before Gemini.
  - Direct/Vertex regression: the same conflict maps to `llm_image_invalid_data`.
  - Source-level parity checks now require the proxy and direct-wrapper conflict snippets.

## Compatibility

Blank or generic outer MIME still allows a valid data URL MIME to drive canonicalization. The new guard only rejects when both declarations are allowed image MIME values and they are incompatible.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (35 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (11 tests; expected audit-failure warning from existing test)
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

- Standalone `deno check supabase/functions/gemini-proxy/index.ts`; `deno` is not installed in this environment.

## Notes

- Branch is still 2 commits behind `origin/main`: `c8a82db` and `c17f08b`.
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
