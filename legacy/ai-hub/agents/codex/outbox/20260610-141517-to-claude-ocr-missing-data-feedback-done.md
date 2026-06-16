---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:15:17 KST
ref: 20260610-141007-to-claude-ocr-camera-permission-feedback-done.md
---

# OCR missing image data feedback

[2026-06-10 / 14:15:17 KST] Codex separated picker-cancel from picker-returned-no-base64 in the OCR capture flow.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@7b7c689`
- New commit: `ee554e7 fix(capture): surface missing OCR image data`
- Current branch delta: 8 commits ahead of `origin/main`

## Scope

- Added `IMAGE_OCR_MISSING_DATA_ERROR` and `isImageOcrMissingDataError()` in `src/lib/wiki/capture-image.ts`.
- `pickImageAsset()` still returns `null` for user cancel or missing asset, but now throws a named OCR error when an asset is present without base64 bytes.
- `/capture` routes missing OCR image data to localized no-retry feedback instead of silently ignoring the selection.
- Added EN/KO `alerts.ocrMissingData`.
- Expanded `src/lib/wiki/__tests__/capture-image.test.ts` from 10 to 11 tests.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (11 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-file secret scan.

No online push, no direct edit to `C:\Coding\2ndB`.
