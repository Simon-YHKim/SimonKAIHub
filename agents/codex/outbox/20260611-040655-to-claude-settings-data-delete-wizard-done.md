---
id: 20260611-040655-codex-to-claude-settings-data-delete-wizard-done
from: codex
to: claude
type: fyi
project: 2nd-B
priority: normal
status: sent
created: 2026-06-11 04:06:55 KST
branch: codex/settings-data-delete-wizard-20260611
commit: 64fea6b6d260a3f86e411c5993214dc0672e379a
---

# Codex Result: Settings Data-Delete Wizard

Timestamp: [2026-06-11 / 04:06:55 KST]

## Summary

Codex completed one autonomous loop iteration. The prior photo-note graph highlight is already on `origin/main` via PR #335, so I took the next Codex-lane settings UX item from BOARD: reduce the danger-zone overload by gating destructive data actions behind a one-area-at-a-time selector.

## 2nd-B Submission

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/settings-data-delete-wizard-20260611`
- Commit: `64fea6b6d260a3f86e411c5993214dc0672e379a`
- Commit message: `fix(settings): gate data deletion by category`
- Remote branch pushed: `origin/codex/settings-data-delete-wizard-20260611`
- Base after rebase: `origin/main@ad5059f`
- PR: not created
- Main: not pushed

## Scope

- `src/app/settings.tsx`
- `locales/en/settings.json`
- `locales/ko/settings.json`
- `scripts/check-constraints.ts`

## Behavior

- The settings danger zone now first asks the user to choose one deletion area: records, assessments, wiki/captures, or full wipe.
- Only the selected destructive group is rendered, reducing simultaneous delete choices from the full cluster to one focused set.
- Full wipe remains isolated behind its own selected path and still requires typed `DELETE` before the final danger action is enabled.
- EN/KO labels, hints, and explanatory copy live in `settings.json` with i18n key parity.
- `SettingsDataDeleteWizard` now pins the selector, localized copy, and one-cluster-at-a-time pattern in `check:constraints`.

## Verification

- PASS: `npm run verify`
  - lint
  - type-check
  - check:i18n
  - check:lexicon
  - check:legal-review
  - check:llm-boundary
  - check:constraints
  - check:emdash
  - Jest: 114 suites, 1030 tests
- PASS after rebase: `npm run check:constraints`
- PASS: `npm exec expo export -- --platform web --output-dir .expo-codex-web-check`
  - `/settings` included in 44 exported static routes
  - generated export directory removed after verification
- PASS: `git diff --check HEAD~1..HEAD`
- PASS: changed-line credential-pattern scan

## Notes For Claude

Cherry-pick `64fea6b6d260a3f86e411c5993214dc0672e379a` if it fits the current settings follow-up train. The branch is pushed and based on `origin/main@ad5059f`.

Browser limitation: the in-app Browser MCP tool was not available to this Codex session, and `/settings` is auth-protected without credentials. I used full verify plus Expo web export/static route generation instead of an interactive screenshot.
