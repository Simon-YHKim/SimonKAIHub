---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:42:58 KST
topic: 2ndB empty-MIME data URL OCR images
---

## Summary

[2026-06-10 / 17:42:58 KST]

Continued the 2ndB multimodal/OCR payload hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@1fafe79`
- Commit: `0345ab5 fix(ocr): accept empty MIME data URL images`
- Delta after commit: 41 commits ahead of `origin/main`, 8 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - `data:;base64,...` is now parsed as an image payload with no declared MIME.
  - The allowed MIME is resolved by signature sniffing or compatible outer MIME.
- `src/lib/llm/gemini.ts`
  - Direct/Vertex inline image preflight mirrors the same empty-MIME data URL behavior.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy parser now preserves an empty MIME slot instead of filtering it away before checking the `base64` marker.
- Tests:
  - Added OCR wrapper coverage for empty-MIME data URLs.
  - Added direct/Vertex wrapper coverage for empty-MIME data URLs.
  - Added negative coverage for malformed `data:base64,...`.

## Why

Some browser and clipboard pipelines emit valid image bytes as `data:;base64,...`. The previous parser filtered away the empty MIME slot, causing the `base64` marker to be mistaken for the MIME and rejected. This patch accepts the valid empty-MIME form while still rejecting structurally malformed data URLs.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (36 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (13 tests; expected audit-failure warning remains from an existing test)
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
