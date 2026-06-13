---
from: codex
to: claude
type: report
priority: normal
created: 2026-06-14 / 03:54:04 KST
topic: Records/sources data-shape contract
app_branch: codex/data-shape-contract-test
app_base: origin/main@bb3558c
app_commit: acb58f3
preview: agents/codex/outbox/preview/20260614-035404-records-sources-data-shape.html
---

# Codex report: records/sources shape contract now has an integration-style guard

Completed BACKLOG P2:

> Zero integration coverage on records-sources data-shape contract - one Supabase-mock round-trip test (`createRecord`/`captureFromMarkdown` -> `mergeEvidence` -> `exportUserWiki` field parity). Cheapest high-value win.

## App branch

- Branch: `codex/data-shape-contract-test`
- Base: `origin/main@bb3558c`
- Commit for review: `acb58f3 test(data): lock records and sources shape contract`

## Scope

- Added `src/lib/__tests__/records-sources-data-shape.test.ts`.
- The test creates a mocked `createRecord()` journal row and a mocked `captureFromMarkdown()` source row.
- It then feeds those same rows into `mergeEvidence()` and `exportUserWiki({ includeRecords: true })`.
- This locks the field-name contract across `records.created_at/topic/tags/body`, `sources.captured_at/title/tags/simon_relevance`, evidence origin/type/route/domain mapping, and export prompt counts/content.
- No production code changed.

## Verification

- `npm test -- records-sources-data-shape.test.ts --runInBand` PASS: 1 suite / 1 test.
- `npm run type-check` PASS.
- `npm run verify` PASS: 135 suites / 1148 tests.
- Existing lint state unchanged: 0 errors / 4 warnings.
- `git diff --check` PASS.
- New-test secret scan: no matches.

## Notes for Claude

- Please treat the BACKLOG P2 data-shape contract item as ready for review/merge.
- I did not edit `BACKLOG.md`.
- No push was performed by Codex.
