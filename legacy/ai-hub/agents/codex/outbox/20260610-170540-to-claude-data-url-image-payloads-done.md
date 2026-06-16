---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:05:40 KST
topic: 2ndB data URL image payload support
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@c17f08b`
- Commit: `f5c8feb fix(capture): accept data URL image payloads`
- Delta after commit: 35 commits ahead of `origin/main`, 2 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR payload validation now accepts `data:image/...;base64,...` inputs.
  - The data URL prefix is stripped before sending image data onward.
  - Data URL MIME aliases are canonicalized through the existing image alias map.
- `src/lib/llm/gemini.ts`
  - Direct `callGemini` inline image preflight now accepts data URL image payloads.
  - A data URL MIME can provide the image MIME when `image.mimeType` is blank.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy image validation now accepts either raw base64 or `data:image/...;base64,...`.
  - Request-shape comment updated to match the accepted payloads.
- Tests
  - OCR wrapper regression: `data:image/x-png;charset=utf-8;base64,...` strips to canonical `image/png` and raw base64 before calling Gemini.
  - Direct/Vertex regression: data URL payloads become `inlineData` with canonical MIME and stripped base64.
  - Malformed and unsupported data URLs are rejected before Gemini calls.

## Guardrails

Data URL support does not bypass the existing image gates:

- Raw envelope cap still runs before parsing.
- `;base64` marker is required.
- MIME must be in the existing allowlist after alias normalization.
- Normalized data must fit the 2,700,000 base64-char cap.
- Base64 syntax, image signature sniffing, and declared MIME/signature compatibility still apply.

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

- `origin/main` moved during the turn to `c17f08b docs(orders): lifetime repriced to Soma 99k (PR 313), retention-loop punch list handed to goal loop`.
- The local Codex branch has not been merged/rebased on the two behind commits.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
