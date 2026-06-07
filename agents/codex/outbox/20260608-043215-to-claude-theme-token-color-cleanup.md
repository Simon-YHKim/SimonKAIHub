---
from: codex
to: claude
type: handoff
priority: normal
topic: theme token color cleanup
created: 2026-06-08 04:32:15 KST
app_worktree: E:\Coding Infra\_worktrees\2ndB-codex
branch: codex/core-label-tail-cleanup
app_commit: d4ca3d8
base: origin/main@74e2f91
verify: PASS
---

# Theme Token Color Cleanup

[2026-06-08 / 04:32:15 KST]
#comm #codex #claude-handoff #2nd-B #ui-ux #theme #verify-pass #anti-slop

## Summary
- Proactive design-first scan after the #250/#251 rebase found two non-art component raw hex colors that could use existing theme tokens.
- Added app commit `d4ca3d8 fix(theme): replace raw component colors with tokens`.
- Branch is clean and `0 2` ahead of `origin/main@74e2f91`.
- Pending local app commits:
  - `3bd45e4 fix(copy): replace README Advisor residue with SecondB`
  - `d4ca3d8 fix(theme): replace raw component colors with tokens`
- No push/PR by Codex.

## Changes
- `src/components/safety/CrisisRouter.tsx`
  - Replaced urgent badge text color `#FFFFFF` with `semantic.text`.
  - Keeps the safety surface inside the documented token system and avoids pure-white UI text.
- `src/components/premium/background.tsx`
  - Replaced hardcoded bottom gradient stop `#05070F` with `cosmic.space950`.
  - Keeps the premium shell background on the documented Cosmic Pixel Graph Village token path.

## Deliberate Non-Changes
- Pixel-art color arrays in `SoulcoreFinalArt` were left untouched because they are asset pixels, not generic UI chrome.
- Web first-paint CSS in `+html.tsx` was left untouched because it runs before React theme hydration and intentionally avoids white flashes/focus loss.
- Documentation/research matches from the scan were not treated as user-screen blockers.

## Verification
- `git diff --check` PASS.
- `npm run type-check` PASS.
- `npm run verify` PASS:
  - lint PASS
  - type-check PASS
  - i18n/lexicon/LLM-boundary/constraints/emdash checks PASS
  - Jest PASS, 98 suites / 859 tests.
- Secret scan on changed files: no matches.
