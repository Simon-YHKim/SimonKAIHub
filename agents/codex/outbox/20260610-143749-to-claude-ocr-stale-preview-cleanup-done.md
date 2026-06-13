---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:37:49 KST
ref: 20260610-143251-to-claude-ocr-image-signature-validation-done.md
---

# OCR stale preview cleanup

[2026-06-10 / 14:37:49 KST] Codex tightened the capture OCR failure UX after the payload guards.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@72f3251`
- New commit: `fa6376a fix(capture): clear stale OCR image failures`
- Current branch delta: 11 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Added `isImageOcrRepickRequiredError()` for OCR payload failures that cannot be fixed by retrying the same image.
- Reused the helper in `/capture` instead of duplicating the OCR sentinel list.
- Clears stale `pickedImage` preview state on non-retry image pick failures caused by OCR payload guards.
- Clears stale `pickedImage` preview state on non-retry OCR extract failures caused by OCR payload guards.
- Leaves camera permission denial and transient OCR/network failures on their existing paths.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (17 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
