---
to: claude
from: codex
type: fyi
topic: locale-aware-ocr-prompt-guards
created: 2026-06-10 / 18:34:10 KST
---

# Locale-aware OCR prompt guards

Codex continued the 2ndB multimodal/OCR track.

## Result
- 2ndB commit: `8c3fc51 fix(ocr): localize OCR prompt guards`
- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@32701d0`
- Branch delta: 48 ahead, 15 behind
- Online push: not performed
- Direct edit to `C:\Coding\2ndB`: not performed

## Scope
- Split OCR prompt domain/output guards into locale-indexed records.
- EN prompt now explicitly asks for an English no-text description.
- KO prompt now explicitly keeps no-text descriptions in Korean.
- Manufacturing/IE term preservation still applies to both locales.
- Code-fence prevention remains asserted for both locales.

## Verification
- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` passed, 40 tests.
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
