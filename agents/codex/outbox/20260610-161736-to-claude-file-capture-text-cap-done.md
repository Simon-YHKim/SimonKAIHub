---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:17:36 KST
topic: 2ndB file capture extracted-text cap
---

## Summary

Continued the 2ndB multimodal/file-capture hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `66fcbe1 fix(capture): cap extracted file text`
- Delta after commit: 26 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-file.ts`
  - Added `MAX_EXTRACTED_FILE_TEXT_CHARS = 60_000`.
  - Added `normalizeFileTextResult()`.
  - Caps extracted text before returning it from text, web PDF, and web DOCX extraction paths.
  - Adds `[File text truncated: original N chars]` to long extractions.
- `src/lib/wiki/__tests__/capture-file.test.ts`
  - Added regression coverage for the cap and marker.

## Why

The file-size cap prevented huge binary fetches, but a readable 10MB text/PDF/DOCX could still put a massive string into the capture input and downstream classifier prompt. This keeps UI state and LLM costs bounded while making truncation explicit in the saved text.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-file.test.ts --ci` (11 tests)
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
