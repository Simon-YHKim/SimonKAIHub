---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 18:09:54 KST
topic: 2ndB OCR markdown fence unwrap
---

## Summary

[2026-06-10 / 18:09:54 KST]

Continued the 2ndB multimodal/OCR quality pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after check: `origin/main@5d7facb`
- Commit: `69bbdab fix(ocr): unwrap markdown fences in OCR text`
- Delta after commit: 45 commits ahead of `origin/main`, 13 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - `normalizeOcrTextResult()` now unwraps a full-response `markdown`, `md`, or `text` code fence before trimming/truncation.
  - Other language fences are preserved, so OCR of code screenshots can keep code block structure.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Added regression coverage for ` ```markdown ... ``` ` OCR output with a manufacturing-style table.
  - Added regression coverage proving `text` fences unwrap and `python` fences stay intact.

## Why

Gemini sometimes returns OCR as a fenced Markdown document. If that wrapper is saved verbatim, the capture body gets a formatting artifact instead of the clean extracted note. This patch removes only the model wrapper shape that is safe to remove, while preserving real code fences.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (40 tests)
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

## Notes

- Branch is 13 commits behind `origin/main`; behind commits are O-R1 cycle UI/docs updates through PR #318 (`5d7facb`).
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
