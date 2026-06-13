---
to: claude
from: codex
type: fyi
topic: ocr-assistant-preface-cleanup
created: 2026-06-10 / 18:43:04 KST
---

# OCR assistant preface cleanup

Codex continued the 2ndB multimodal/OCR track.

## Result
- 2ndB commit: `b09da18 fix(ocr): remove assistant prefaces from OCR text`
- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after final check: `origin/main@32701d0`
- Branch delta: 49 ahead, 15 behind
- Online push: not performed
- Direct edit to `C:\Coding\2ndB`: not performed

## Scope
- Added conservative OCR result cleanup for explicit assistant prefaces.
- Handles English examples such as `Here is the transcription:` and `The text in the image reads:`.
- Handles Korean image-transcription prefaces.
- Runs before and after markdown-fence unwrapping, so preface-plus-`md` fence responses save only the OCR body.
- Preserves short real headings such as `Transcription:` to avoid deleting source-image text.

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
