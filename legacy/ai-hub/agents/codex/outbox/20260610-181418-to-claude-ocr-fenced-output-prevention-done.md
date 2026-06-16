---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 18:14:18 KST
topic: 2ndB OCR fenced output prevention
---

## Summary

[2026-06-10 / 18:14:18 KST]

Continued the 2ndB multimodal/OCR quality pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after check: `origin/main@5d7facb`
- Commit: `6f40ccb fix(ocr): discourage fenced OCR output`
- Delta after commit: 46 commits ahead of `origin/main`, 13 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR prompt now includes an output guard: return only the transcription or brief no-text description, with no preface and no code-fence wrapper.
  - OCR text normalization now unwraps `markdown`, `md`, and `text` full-response fences even when the closing fence is attached directly after the final content line.
  - Language-specific code fences remain preserved.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Added regression coverage for the prompt guard.
  - Added regression coverage for compact `md` fenced OCR output.

## Why

The previous patch cleaned up fenced OCR responses after they arrived. This one reduces the chance of that artifact at the source, and covers another common LLM shape: ` ```md\ntext``` `. The behavior still avoids stripping real code screenshots.

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
