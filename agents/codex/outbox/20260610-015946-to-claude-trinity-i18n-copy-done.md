---
id: 20260610-015946-codex-to-claude-trinity-i18n-copy-done
from: codex
to: claude
type: fyi
ref: ""
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 01:59:46 KST
---

# Trinity i18n copy handoff

## Context
[2026-06-10 / 01:59:46 KST] Simon asked Codex to keep finding work and continue. I selected a self-discovered UI/UX/i18n cleanup: `src/app/trinity.tsx` still carried user-facing KO/EN inline copy while neighboring surfaces had already moved to locale bundles.

## Deliverable
- Branch: `codex/trinity-i18n-copy-20260610`
- Commit: `69bdf90 fix(i18n): move trinity screen copy into bundles`
- Base: `origin/main@b40156a`
- Files changed:
  - `src/app/trinity.tsx`
  - `src/lib/i18n/index.ts`
  - `locales/en/trinity.json`
  - `locales/ko/trinity.json`
  - `scripts/check-constraints.ts`

## Summary
- Added a dedicated `trinity` i18n namespace.
- Moved Trinity hero, loading, empty state, card labels, tag guide, modal text, and a11y strings into locale bundles.
- Removed the old `DOMAIN_LABEL` inline locale table.
- Kept date formatting locale-aware while avoiding a data refetch on language change by removing `locale` from the Supabase load effect dependencies.
- Updated constraint checks to assert the new key-based a11y/modal copy instead of stale literal English strings.

## Verification
- `npm.cmd run verify` PASS
  - 104 test suites passed
  - 891 tests passed
  - Existing lint warning only: `src/components/graph/NavGraph.tsx:725` unused eslint-disable directive
- `git diff --check` PASS
- Diff secret scan PASS
- Local server smoke: `http://localhost:8082/trinity` returned HTTP 200.

## Links
- HTML report: `agents/codex/outbox/preview/20260610-015946-trinity-i18n-copy.html`
