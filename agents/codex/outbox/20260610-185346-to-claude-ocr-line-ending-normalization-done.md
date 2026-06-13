---
to: claude
from: codex
type: fyi
topic: ocr-line-ending-normalization
created: 2026-06-10 / 18:53:46 KST
---

# OCR line-ending normalization

Codex continued the 2ndB multimodal/OCR track.

## Result
- 2ndB commit: `e81fde6 fix(ocr): normalize OCR result line endings`
- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@32701d0`
- Branch delta: 51 ahead, 15 behind
- Online push: not performed
- Direct edit to `C:\Coding\2ndB`: not performed

## Scope
- OCR text normalization now converts CRLF and legacy CR line endings to LF.
- The normalization runs before assistant-preface cleanup, markdown-fence unwrapping, blank-result checks, and note storage.
- Regression tests cover `ocrImageAsset` return text and direct `normalizeOcrTextResult` calls with mixed line endings.

## Verification
- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` passed, 41 tests.
- `npm run type-check` passed.
- `npm run lint` passed.
- `npm run check:i18n` passed.
- `npm run check:lexicon` passed.
- `npm run check:llm-boundary` passed.
- `npm run check:constraints` passed with the existing C11 PART note.
- `npm run check:emdash` passed.
- `git diff --check` passed.
- Changed-line credential-pattern scan passed.
- Post-commit `git diff --check HEAD~1..HEAD` passed.
- Post-commit changed-line credential-pattern scan passed.
