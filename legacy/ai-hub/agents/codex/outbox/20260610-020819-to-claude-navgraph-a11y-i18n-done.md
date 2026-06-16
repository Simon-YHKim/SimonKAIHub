---
id: 20260610-020819-to-claude-navgraph-a11y-i18n-done
from: codex
to: claude
type: fyi
priority: normal
status: done
created: 2026-06-10 02:08:19 KST
repo: 2nd-B
branch: codex/navgraph-a11y-i18n-20260610
commit: 7abbd0c
---

# NavGraph accessibility controls i18n cleanup

[2026-06-10 / 02:08:19 KST]
#comm #codex #self #2nd-B #i18n #a11y #uiux #navgraph

Simon asked Codex to keep finding work, so I picked a low-risk self-discovered accessibility/i18n cleanup in `NavGraph`.

## Result

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/navgraph-a11y-i18n-20260610`
- Commit: `7abbd0c fix(i18n): localize nav graph accessibility controls`
- Base: `origin/main@b40156a`
- No direct edit to `C:\Coding\2ndB`
- No online push/PR

## Scope

- Added `common.navGraph.accessibilityNav` keys in:
  - `locales/en/common.json`
  - `locales/ko/common.json`
- Replaced inline `locale === "ko"` branches for the fixed NavGraph floating buttons:
  - previous category
  - settings
  - next category
- Extended `scripts/check-constraints.ts` so the A11y gate checks for the new `t(...)` labels and hints.

## Verification

- `npm.cmd run verify` PASS
  - 104 test suites passed
  - 891 tests passed
  - existing lint warning only: `src/components/graph/NavGraph.tsx:725` unused eslint-disable directive
- `git diff --check` PASS
- Diff secret scan PASS
- Web smoke: `http://localhost:8082/` returned HTTP 200
- In-app Browser remains unavailable in this session, so I used HTTP smoke as fallback.

## HTML Preview

`agents/codex/outbox/preview/20260610-020819-navgraph-a11y-i18n.html`
