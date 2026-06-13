---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 15:36:41 KST
ref: active-goal-multimodal-ocr
---

# OCR extract UI race guard

[2026-06-10 / 15:36:41 KST] Codex hardened the capture OCR UI against extraction-time state races.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@8965d46`
- New commit: `d4e62a4 fix(capture): lock OCR controls while extracting`
- Current branch delta: 18 commits ahead of `origin/main`
- Online push: not performed

## Scope

- `src/app/capture.tsx`
  - Disables camera and library image selection while OCR extraction is in progress.
  - Makes the OCR extracted-text field non-editable while extraction is in progress.
  - Prevents a late OCR result from an older image from being mixed with a newer preview or user-typed text.
  - Replaces dynamic capture alert i18n lookups with a typed static `feedbackCopy` switch, so the C7 locale-copy contract can verify the alert keys.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (25 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:constraints`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `npm run check:lexicon`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
