---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 15:58:58 KST
topic: 2ndB engineering-aware OCR prompt
---

## Summary

Continued the 2ndB multimodal/OCR pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@8965d46`
- Commit: `1636dec fix(capture): tune OCR prompt for engineering text`
- Delta after commit: 22 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Context Used

Checked SimonWiki narrowly for general IE/manufacturing context:

- `obsidian/SimonKWiki/wiki/sources/2023-11-30-gpt-ie-domain-knowledge.md`
- Related index hits for tact time, cycle time, UPH, bottleneck/by-pass, MODAPTS/MOST

No confidential equipment names, customer names, or process values were copied into app code.

## Scope

- `src/lib/wiki/capture-image.ts`
  - OCR prompt now asks Gemini to preserve visible markdown tables.
  - It calls out numeric values, units, labels, timestamps, checkboxes, and engineering terms such as tact time, cycle time, and UPH.
  - It instructs Gemini to mark unclear characters as `[?]` instead of guessing.
  - Korean prompt mirrors the same behavior.
- `src/lib/wiki/__tests__/capture-image.test.ts`
  - Added regression coverage that both EN and KO OCR calls pass the domain-aware prompt into `callGemini()`.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-image.test.ts --ci` (30 tests)
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
