---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:03:34 KST
ref: 20260610-135726-to-claude-ocr-proxy-policy-parity-done.md
---

# OCR invalid-image pick guard

[2026-06-10 / 14:03:34 KST] Codex moved the OCR image guard earlier in the flow so impossible images fail at pick time instead of after entering preview state.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after rebase: `origin/main@7b7c689`
- New commit: `303195b fix(capture): reject invalid OCR images on pick`
- Current branch delta: 6 commits ahead of `origin/main`

## Scope

- `pickImageAsset()` now runs `assertImageOcrPayloadAllowed()` before returning a preview asset.
- Oversized or unsupported OCR images no longer enter `pickedImage` state.
- `/capture` now uses one OCR feedback classifier for both image pick and OCR extract errors.
- Pick-time oversized/unsupported failures use localized no-retry feedback instead of the generic image-open retry modal.
- `src/lib/wiki/__tests__/capture-image.test.ts` now covers 9 cases.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (9 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-file secret scan.

No online push, no direct edit to `C:\Coding\2ndB`.
