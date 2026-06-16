---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:25:00 KST
topic: 2ndB file capture generic MIME inference
---

## Summary

Continued the 2ndB multimodal/file-capture hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `3b9189c fix(capture): infer generic file MIME from name`
- Delta after commit: 27 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/lib/wiki/capture-file.ts`
  - Added generic MIME handling for blank, `application/octet-stream`, `binary/octet-stream`, and `application/x-unknown`.
  - Added conservative filename-extension inference for supported extraction types: TXT, Markdown, CSV, JSON, XML, HTML, PDF, DOCX.
  - `pickFile()` now passes the picked filename into MIME normalization.
  - Explicit non-generic MIME from the picker still wins over the extension.
- `src/lib/wiki/__tests__/capture-file.test.ts`
  - Added regression coverage for extension inference.
  - Added `pickFile()` coverage proving a generic `.md` pick reaches text extraction and returns stable MIME metadata.

## Why

Some picker/platform combinations return useful files with missing or generic MIME metadata. Before this change, supported files such as `line-study.md` or `scan.pdf` could skip extraction and save only filename/MIME metadata. The new inference keeps those files on the existing extraction paths without widening the accepted file families.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-file.test.ts --ci` (13 tests)
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
