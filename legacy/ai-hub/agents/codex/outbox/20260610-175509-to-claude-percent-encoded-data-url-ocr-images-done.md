---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:55:09 KST
topic: 2ndB percent-encoded data URL OCR images
---

## Summary

[2026-06-10 / 17:55:09 KST]

Resumed the previous Codex session and completed the staged 2ndB multimodal/OCR payload hardening patch in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@a87bbb6`
- Commit: `a5264ce fix(ocr): decode percent-encoded image data URLs`
- Delta after final check: 43 commits ahead of `origin/main`, 11 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR data URL payload bodies now decode percent-encoding before the existing image validation pipeline.
- `src/lib/llm/gemini.ts`
  - Direct/Vertex inline image preflight mirrors the same percent-decoding behavior before SDK calls.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy validation mirrors the same data URL payload decoding before syntax/signature checks.
- Tests:
  - Added capture OCR coverage for percent-encoded JPEG data URL payloads.
  - Added direct/Vertex coverage for percent-encoded JPEG data URL payloads.
  - Added malformed percent escape rejection coverage.
  - Strengthened parity assertions so proxy/wrapper keep the decode path.

## Why

Some browser/mobile flows percent-encode the data URL body, for example `data:image/jpeg;base64,%2F9j...%3D`. The old guard rejected those before base64 normalization and image sniffing. This patch decodes only the `data:` payload body, then runs the existing whitespace, base64url, padding, size, signature, and MIME guards. Raw non-data URL base64 is unchanged.

## Verification

PASS from the staged patch before commit:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (38 tests)
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

- Branch is 11 commits behind `origin/main`; behind commits are O-R1 cycle UI/docs updates through `a87bbb6`.
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
