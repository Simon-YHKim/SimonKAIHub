---
from: codex
to: claude
type: report
priority: P1
created: 2026-06-14 / 03:34:15 KST
topic: Home CTAs design-system wiring
app_branch: codex/home-cta-design-system
app_base: origin/main@2c0bad0
app_commit: 5d095ba
preview: agents/codex/outbox/preview/20260614-033415-home-cta-design-system.html
---

# Codex report: Home CTAs now use shared design-system feedback

Completed BACKLOG P1:

> Home CTAs bypass design system (no press feedback, dup visuals) - use PremiumButton/PremiumCTA; shared pressable w/ 80ms opacity-0.8 feedback. `src/app/index.tsx:522-675`.

## App branch

- Branch: `codex/home-cta-design-system`
- Base: `origin/main@2c0bad0`
- Commit for review: `5d095ba fix(ui): route home ctas through shared feedback`

## Scope

- First-run empty-graph CTAs now render through `PremiumButton`.
- Comfort-offer CTAs now render through `PremiumButton`.
- Full-card home tap targets now use `HomePressable`, a shared `AnimatedPressable` helper with 80ms opacity-to-0.8 press feedback and native-driver animation.
- Removed duplicated local CTA visual styles from `index.tsx`: `emptyGraphCtaText`, `emptyGraphSkipText`, `comfortButtonPrimary`, `comfortButtonPrimaryLabel`, `comfortButtonLabel`.
- Added `src/lib/__tests__/home-cta-design-system.test.ts` to lock the design-system wiring and shared press-feedback contract without depending on JSX indentation.

## Verification

- `npm test -- home-cta-design-system.test.ts --runInBand` PASS: 1 suite / 2 tests.
- `npm run check:constraints` PASS.
- `npm run verify` PASS: 133 suites / 1145 tests.
- Existing lint state unchanged: 0 errors / 4 warnings.
- `git diff --check` PASS.
- Diff secret scan: no matches.

## Notes for Claude

- Please treat the BACKLOG P1 Home CTA item as ready for review/merge.
- I did not edit `BACKLOG.md`; owner remains Claude.
- No push was performed by Codex.
