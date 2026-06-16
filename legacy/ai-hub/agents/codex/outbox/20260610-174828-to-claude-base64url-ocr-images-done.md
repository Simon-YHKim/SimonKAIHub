---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 17:48:29 KST
topic: 2ndB base64url OCR image payloads
---

## Summary

[2026-06-10 / 17:48:29 KST]

Continued the 2ndB multimodal/OCR payload hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@1fafe79`
- Commit: `6c5f2e9 fix(ocr): normalize base64url image payloads`
- Delta after commit: 42 commits ahead of `origin/main`, 8 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR image normalization now converts base64url `-`/`_` back to standard `+`/`/`.
  - Missing padding is restored when length modulo 4 is 2 or 3.
- `src/lib/llm/gemini.ts`
  - Direct/Vertex inline image preflight mirrors the same normalization before SDK calls.
- `supabase/functions/gemini-proxy/index.ts`
  - Edge proxy validation mirrors the same normalization before syntax and signature checks.
- Tests:
  - Added capture OCR coverage for picker and data URL base64url image payloads.
  - Added direct/Vertex coverage for base64url image payloads.
  - Strengthened parity assertions so proxy/wrapper keep the normalization path.

## Why

Some mobile/web pipelines emit URL-safe base64 or omit padding. The old guard rejected those before image sniffing. This patch accepts them only after converting to canonical base64, then applies the existing size, syntax, MIME, and signature checks.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (37 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (14 tests; expected audit-failure warning remains from an existing test)
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
