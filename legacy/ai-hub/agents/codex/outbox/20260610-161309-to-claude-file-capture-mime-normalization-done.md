---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:13:09 KST
topic: 2ndB file capture MIME normalization
---

## Summary

Continued the 2ndB multimodal capture hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Final base after rebase: `origin/main@7327c5e`
- Commit: `30f2f31 fix(capture): normalize picked file MIME`
- Delta after commit: 25 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Rebase Note

`origin/main` advanced during the turn to:

- `7327c5e docs(orders): goal cycle-5 closed - advisor gate wired via PR 312, 12 PRs today`

The branch rebased cleanly onto that commit, then focused checks and static gates were rerun.

## Scope

- `src/lib/wiki/capture-file.ts`
  - Added `normalizeFileMimeType()`.
  - `pickFile()` now stores normalized MIME metadata.
  - `extractText()` now trims, lowercases, and strips MIME parameters before matching extraction handlers.
- `src/lib/wiki/__tests__/capture-file.test.ts`
  - Covers `TEXT/PLAIN; charset=UTF-8`, PDF with parameters, upper-case DOCX MIME, blank MIME fallback, and picker-returned MIME normalization.

## Why

Document pickers often return MIME strings with case differences or parameters. Before this change, those values missed the text/PDF/DOCX extraction paths and fell back to metadata-only capture even when readable text was available.

## Verification

PASS after rebase:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-file.test.ts --ci` (10 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

## Notes

- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
