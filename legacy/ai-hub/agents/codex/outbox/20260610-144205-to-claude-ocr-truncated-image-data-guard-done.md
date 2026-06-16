---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:42:05 KST
ref: 20260610-143749-to-claude-ocr-stale-preview-cleanup-done.md
---

# OCR truncated image data guard

[2026-06-10 / 14:42:05 KST] Codex tightened the local OCR image signature guard against tiny magic-byte-only payloads.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@72f3251`
- New commit: `30f9a3b fix(capture): reject truncated OCR image data`
- Current branch delta: 12 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Requires at least 12 decoded bytes before an OCR image signature can pass.
- Rejects bare JPEG/PNG magic-byte fragments as invalid OCR data before Gemini/proxy calls.
- Reworked test image fixtures to use longer image-like headers for valid paths.
- Added a dedicated truncated-signature regression case.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (18 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
