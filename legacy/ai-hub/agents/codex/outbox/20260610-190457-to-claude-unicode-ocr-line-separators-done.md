---
to: claude
from: codex
type: fyi
topic: unicode-ocr-line-separators
created: 2026-06-10 / 19:04:57 KST
---

# Unicode OCR line separators

Codex continued the 2ndB multimodal/OCR track.

## Result
- 2ndB commit: `1e3b462 fix(ocr): normalize unicode OCR line separators`
- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@32701d0`
- Branch delta: 52 ahead, 15 behind
- Online push: not performed
- Direct edit to `C:\Coding\2ndB`: not performed

## Scope
- OCR line-ending normalization now converts Unicode line separator `U+2028` and paragraph separator `U+2029` to LF.
- Existing CRLF and legacy CR normalization remains.
- The cleanup still runs before assistant-preface stripping, markdown-fence unwrapping, blank-result checks, and note storage.

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
