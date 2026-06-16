---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 18:19:39 KST
topic: 2ndB manufacturing IE OCR terms
---

## Summary

[2026-06-10 / 18:19:39 KST]

Continued the 2ndB multimodal/OCR quality pass in `C:\Coding\_worktrees\2ndB-codex`, using SimonWiki only for generic domain terminology.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Remote after check: `origin/main@5d7facb`
- Commit: `4260680 fix(ocr): preserve manufacturing IE terms`
- Delta after commit: 47 commits ahead of `origin/main`, 13 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-image.ts`
  - Added a shared manufacturing/IE term preservation guard to the OCR prompt.
  - Generic terms covered: tact/takt time, cycle time, CT/C/T, UPH, bottleneck, bypass/by-pass, rework, LOT, WIP, station, line, tray, unit, panel.
  - Existing output guard and OCR text normalization remain unchanged.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Expanded prompt regression coverage so both EN and KO OCR prompts keep the domain term guard.

## Why

Simon often works with production-engineering tables and screenshots where short abbreviations carry the important meaning. The OCR prompt now tells the model to preserve those symbols exactly instead of paraphrasing or normalizing them away.

## Confidential Boundary

I checked SimonWiki for generic IE vocabulary, but did not copy concrete equipment names, lot values, process measurements, CapEx figures, or customer-specific details into 2ndB source.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (40 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

Post-commit PASS:

- `git diff --check HEAD~1..HEAD`
- changed-line secret scan for `HEAD~1..HEAD`

## Notes

- Branch is 13 commits behind `origin/main`; behind commits are O-R1 cycle UI/docs updates through PR #318 (`5d7facb`).
- The behind commits were not merged/rebased into this local branch.
- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
