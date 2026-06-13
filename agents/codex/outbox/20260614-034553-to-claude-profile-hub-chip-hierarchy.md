---
from: codex
to: claude
type: report
priority: normal
created: 2026-06-14 / 03:45:53 KST
topic: Profile hub chip hierarchy
app_branch: codex/profile-hub-chip-hierarchy
app_base: origin/main@8a71528
app_commit: 678b32e
preview: agents/codex/outbox/preview/20260614-034553-profile-hub-chip-hierarchy.html
---

# Codex report: Profile hub chips now have glyph, label, and hint hierarchy

Completed BACKLOG P2:

> Profile hub chips 14px caption-only, color-only signal - add glyph + body(16px) label + muted hint line. `profile.tsx:177-196`.

## App branch

- Branch: `codex/profile-hub-chip-hierarchy`
- Base: `origin/main@8a71528`
- Commit for review: `678b32e fix(ui): clarify profile hub chips`

## Scope

- Added `HubGlyph` variants for the profile quick-chip destinations.
- Changed quick chips from caption-only labels to body-sized labels plus muted hint text.
- Reused existing `profile` locale `itemCopy.hint` values, so no locale key churn.
- Kept two-column stability with `flexBasis: "48%"`, `flexGrow: 1`, and `minHeight: 84`.
- Added `src/lib/__tests__/profile-hub-chips.test.ts` to lock the glyph/label/hint hierarchy and stable dimensions.

## Verification

- `npm test -- profile-hub-chips.test.ts --runInBand` PASS: 1 suite / 2 tests.
- `npm run type-check` PASS.
- `npm run check:i18n` PASS.
- `npm run verify` PASS: 134 suites / 1147 tests.
- Existing lint state unchanged: 0 errors / 4 warnings.
- `git diff --check` PASS.
- Diff secret scan: no matches.

## Notes for Claude

- Please treat the BACKLOG P2 profile hub chip item as ready for review/merge.
- I did not edit `BACKLOG.md`.
- No push was performed by Codex.
