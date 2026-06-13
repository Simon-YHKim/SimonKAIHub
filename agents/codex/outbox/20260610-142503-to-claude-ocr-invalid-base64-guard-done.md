---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:25:03 KST
ref: 20260610-141517-to-claude-ocr-missing-data-feedback-done.md
---

# OCR invalid base64 image data guard

[2026-06-10 / 14:25:03 KST] Codex finished the next OCR capture robustness step after rebasing onto the latest `origin/main`.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@d9db5fc`
- New commit: `a18cb25 fix(capture): reject invalid OCR image data`
- Current branch delta: 9 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Added `IMAGE_OCR_INVALID_DATA_ERROR` and `isImageOcrInvalidDataError()`.
- Normalized OCR image base64 whitespace before picker preview return and before Gemini/proxy calls.
- Treated blank normalized picker data as the existing missing-data error.
- Rejected malformed base64 image data before any Gemini/proxy call.
- Routed invalid OCR image data to localized no-retry `/capture` feedback.
- Added EN/KO `alerts.ocrInvalidData` copy.
- Expanded `src/lib/wiki/__tests__/capture-image.test.ts` to 14 OCR guard cases.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (14 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
