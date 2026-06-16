---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 15:18:03 KST
ref: active-goal-multimodal-ocr
---

# Proxy OCR image payload guard

[2026-06-10 / 15:18:03 KST] Codex closed the server-side OCR image payload validation gap in `gemini-proxy`.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@8965d46`
- New commit after final rebase: `ab1ecf3 fix(proxy): reject malformed OCR image payloads`
- Current branch delta: 17 commits ahead of `origin/main`
- Online push: not performed

## Scope

- `supabase/functions/gemini-proxy/index.ts`
  - Rejects non-object/array image payloads.
  - Rejects missing image MIME/data.
  - Preserves proxy MIME allowlist and base64 size cap.
  - Normalizes base64 whitespace before forwarding to Gemini.
  - Rejects invalid base64 syntax.
  - Rejects truncated, non-image, or unknown image signatures.
  - Rejects declared MIME/signature mismatch.
  - Allows HEIC/HEIF signature compatibility.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Extends proxy/client policy parity test to keep the proxy syntax/signature guard from regressing.
- `src/lib/llm/types.ts`
  - Updates the inline image comment to match the proxy's actual authority: MIME, size, syntax, and signature.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (21 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
