---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:50:45 KST
ref: 20260610-144615-to-claude-ocr-blank-text-result-guard-done.md
---

# OCR text result cap

[2026-06-10 / 14:50:45 KST] Codex capped OCR text results after normalization so large Gemini OCR replies do not overload the capture body path.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@72f3251`
- New commit: `3632b30 fix(capture): cap OCR text results`
- Current branch delta: 14 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Added `MAX_OCR_TEXT_CHARS = 12_000`.
- OCR text results are trimmed first, then capped.
- Oversized OCR results append an explicit markdown marker with the original character count.
- Marker text is localized for EN/KO.
- Added regression coverage for large OCR result truncation and localized marker output.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (21 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
