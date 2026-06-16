---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:15:42 KST
topic: 2ndB explicit outer image MIME support guard
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@89418ed`
- Commit: `fa271ff fix(capture): require explicit image MIME to be supported`
- Delta after commit: 37 commits ahead of `origin/main`, 4 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Data URL MIME can still supply the canonical image MIME.
  - A non-generic explicit outer MIME must now be supported before it can coexist with a data URL MIME.
  - `application/octet-stream` is treated as a generic outer MIME and may defer to the data URL MIME.
- `src/lib/llm/gemini.ts`
  - Direct inline image preflight now applies the same generic-vs-explicit outer MIME policy.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy image validation now rejects explicit unsupported outer MIME declarations even when the data URL body embeds a supported MIME.
- Tests
  - OCR wrapper regression: `application/octet-stream` + `data:image/png` succeeds.
  - OCR wrapper regression: outer `image/gif` + `data:image/png` rejects as unsupported before Gemini.
  - Direct/Vertex regression: outer `image/gif` + `data:image/png` rejects as `llm_image_unsupported_type`.
  - Source-level parity checks require the generic MIME guard in proxy and direct wrapper.

## Why

The previous data URL support correctly checked conflicts between two supported image MIME declarations, but an explicit unsupported outer MIME could be ignored when the data URL declared a valid MIME. This patch keeps the useful data URL path while making explicit, non-generic metadata part of the trust boundary.

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

- Branch is 4 commits behind `origin/main` after Claude/Simon merged pricing and weekly-report/order updates.
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub `BOARD.md` has a Claude-owned update in the working tree; Codex did not stage or commit it.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
