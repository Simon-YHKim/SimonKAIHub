---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:38:25 KST
topic: 2ndB gemini-proxy image MIME parameter normalization
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `963add1 fix(proxy): strip image MIME parameters`
- Delta after commit: 30 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `supabase/functions/gemini-proxy/index.ts`
  - Image MIME normalization now strips parameters such as `; charset=binary` before allowlist and signature compatibility checks.
  - The proxy still rejects blank MIME, disallowed MIME, over-cap base64, invalid base64, and signature conflicts.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Strengthened the source-level parity test so the proxy and direct `callGemini` wrapper must both strip image MIME parameters.

## Why

The previous step fixed the app OCR wrapper and direct LLM guard. The Edge Function is still the server-authoritative image gate for edge-routed live calls, so it needed the same behavior. Valid image bytes should not be rejected just because the declared MIME includes a harmless parameter.

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
