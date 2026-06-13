---
id: 20260610-021517-to-claude-web-html-lang-done
from: codex
to: claude
type: fyi
priority: normal
status: done
created: 2026-06-10 02:15:17 KST
repo: 2nd-B
branch: codex/web-html-lang-20260610
commit: aeb2e3b
---

# Web root language accessibility fix

[2026-06-10 / 02:15:17 KST]
#comm #codex #self #2nd-B #a11y #i18n #web

Simon asked Codex to keep finding work, so I picked the audit item where `src/app/+html.tsx` hardcoded `<html lang="ko">` for all web users.

## Result

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/web-html-lang-20260610`
- Commit: `aeb2e3b fix(a11y): align web root language with locale`
- Base: `origin/main@b40156a`
- No direct edit to `C:\Coding\2ndB`
- No online push/PR

## Scope

- Changed the Expo web shell root from hardcoded `lang="ko"` to `lang="en"`.
- Added a first-head `LANGUAGE_BOOTSTRAP_SCRIPT` that mirrors web i18n detection:
  - saved `localStorage["2nd-brain:locale"]` wins when it is `en` or `ko`
  - otherwise Korean browser locale sets root lang to `ko`
  - fallback remains `en`
- Added a `WebHtmlLanguage` constraint to prevent reintroducing hardcoded Korean root lang.
- Marked the two matching rows in `docs/AUDIT_2026-06-03.md` complete.

## Verification

- `npm.cmd run verify` PASS
  - 104 test suites passed
  - 891 tests passed
  - existing lint warning only: `src/components/graph/NavGraph.tsx:725` unused eslint-disable directive
- `git diff --check` PASS
- Changed-line diff secret scan PASS
  - full diff scan had a false positive on the existing audit text `tokens.ts`
- Web smoke:
  - `http://localhost:8082/` returned HTTP 200
  - response HTML contained root `lang="en"`
  - response HTML contained `2nd-brain:locale` and `document.documentElement.lang`
- In-app Browser remains unavailable in this session, so I used HTTP smoke as fallback.

## HTML Preview

`agents/codex/outbox/preview/20260610-021517-web-html-lang.html`
