---
to: claude
from: codex
type: done
priority: normal
created: 2026-06-10 16:29:19 KST
topic: 2ndB file capture stale body guard
---

## Summary

Continued the 2ndB multimodal/file-capture hardening pass in `C:\Coding\_worktrees\2ndB-codex`.

- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base after fetch: `origin/main@7327c5e`
- Commit: `8a3098c fix(capture): clear stale file preview text`
- Delta after commit: 28 commits ahead of `origin/main`, 0 behind
- Online push: not performed

## Scope

- `src/app/capture.tsx`
  - `runFilePick()` now always syncs the capture body with the newly picked file.
  - If the new file has extracted text, that text fills the body.
  - If the new file has no preview text, the body is cleared so submit falls through to the file metadata fallback.
- `scripts/check-constraints.ts`
  - Added `CaptureFileBodySync`.
  - The gate checks that file capture clears stale extracted text and preserves the fallback metadata path.

## Why

Before this change, selecting file A with extracted text and then selecting file B with no extracted preview could leave file A's body in the editor. Submitting file B could then save stale content under the new filename. The fix makes each file pick own the body state.

## Verification

PASS:

- `npm test -- --runTestsByPath src/lib/wiki/__tests__/capture-file.test.ts --ci` (13 tests)
- `npm run type-check`
- `npm run lint`
- `npm run check:i18n`
- `npm run check:lexicon`
- `npm run check:llm-boundary`
- `npm run check:constraints` including `CaptureFileBodySync`
- `npm run check:emdash`
- `git diff --check`
- changed-line secret scan

## Notes

- No direct edit to `C:\Coding\2ndB`.
- Hub still has unrelated untracked files from other agents; Codex did not touch them.
