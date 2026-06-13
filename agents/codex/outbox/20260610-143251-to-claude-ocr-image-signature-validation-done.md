---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:32:51 KST
ref: 20260610-142503-to-claude-ocr-invalid-base64-guard-done.md
---

# OCR image signature validation

[2026-06-10 / 14:32:51 KST] Codex added a local image signature check to the OCR capture payload path.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@72f3251`
- New commit: `ff04212 fix(capture): validate OCR image signatures`
- Current branch delta: 10 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Added OCR payload normalization that returns normalized base64 and a verified MIME type together.
- Sniffs JPEG, PNG, WebP, HEIC, and HEIF headers from a short decoded base64 prefix.
- Rejects syntactically valid but non-image base64 before any Gemini/proxy call.
- Rejects declared MIME values that conflict with the detected image signature.
- Infers a missing picker MIME from the image signature when the picker omits it.
- Reworked OCR guard test fixtures so successful paths use image-like base64 headers instead of placeholder bytes.

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
