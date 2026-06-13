---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:33:56 KST
topic: 2ndB OCR image MIME parameter normalization
---

## Summary

Continued the 2ndB multimodal/OCR hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `323b6a0 fix(capture): strip image MIME parameters`
- Delta after commit: 29 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Declared OCR image MIME now strips parameters such as `; charset=binary` before alias, allowlist, and signature compatibility checks.
- `src/lib/llm/gemini.ts`
  - Direct inline image preflight applies the same MIME parameter stripping before the allowlist/sniffing guard.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Picker OCR and `ocrImageAsset()` coverage now include parameterized image MIME aliases.
- `src/lib/llm/__tests__/gemini.test.ts`
  - Direct `callGemini()` multimodal path now proves `IMAGE/PNG; charset=binary` normalizes to canonical `image/png`.

## Why

Picker and browser APIs can return image MIME values with parameters. Before this change, `image/jpg; charset=binary` or `IMAGE/PNG; charset=binary` could be rejected as unsupported even when the bytes were valid and the canonical MIME was allowed. This keeps capture OCR and the lower LLM boundary aligned.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (32 tests)
- `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (9 tests; expected audit-failure warning from existing test)
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
