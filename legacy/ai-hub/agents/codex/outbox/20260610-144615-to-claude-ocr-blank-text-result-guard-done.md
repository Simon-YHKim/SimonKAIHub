---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:46:15 KST
ref: 20260610-144205-to-claude-ocr-truncated-image-data-guard-done.md
---

# OCR blank text result guard

[2026-06-10 / 14:46:15 KST] Codex tightened the OCR result path so a blank Gemini reply does not leave the capture screen in a dead-end state.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@72f3251`
- New commit: `0aca8fb fix(capture): reject blank OCR text results`
- Current branch delta: 13 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Added `IMAGE_OCR_EMPTY_RESULT_ERROR` and `isImageOcrEmptyResultError()`.
- Trims OCR result text before returning it to `/capture`.
- Rejects blank or whitespace-only OCR replies as a retryable read failure.
- Routes the empty-result sentinel through the existing localized `alerts.ocrRead` feedback.
- Added regression coverage for trim normalization, blank result rejection, and the sentinel helper.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (20 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
