---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:59:24 KST
topic: 2ndB raw image base64 envelope cap parity
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after fetch: `origin/main@c8a82db`
- Commit: `fbd0aa7 fix(capture): cap raw image base64 envelopes`
- Delta after commit: 34 commits ahead of `origin/main`, 1 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Added `MAX_OCR_IMAGE_RAW_BASE64_BYTES = MAX_OCR_IMAGE_BASE64_BYTES + 100_000`.
  - OCR payload validation now rejects raw base64 envelopes before whitespace normalization when they exceed that cap.
- `src/lib/llm/gemini.ts`
  - Added `MAX_INLINE_IMAGE_RAW_BASE64_LEN = MAX_INLINE_IMAGE_BASE64_LEN + 100_000`.
  - Direct inline image preflight now rejects whitespace-heavy image strings before normalization.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Added proxy/direct raw-envelope parity checks.
  - Added a regression test for raw strings that normalize down to a small valid image but exceed the raw envelope.
- `src/lib/llm/__tests__/gemini.test.ts`
  - Added the matching direct/Vertex preflight regression.

## Why

The proxy already had a two-stage image size policy: allow normal line-wrapped base64 to normalize under the real cap, but fail closed on whitespace-heavy request-body abuse. The app OCR wrapper and direct `callGemini` path only enforced the normalized cap. This keeps the three image boundaries aligned and reduces client-side parsing/allocation exposure before any Gemini call.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (33 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (10 tests; expected audit-failure warning from existing test)
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

- `origin/main` moved during the turn to `c8a82db feat(plans): reprice lifetime - move from Brain 299k to Soma 99k entry tier (#313)`.
- The local Codex branch has not been merged/rebased on that commit.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
