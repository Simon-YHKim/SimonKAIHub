---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 15:43:05 KST
ref: active-goal-multimodal-ocr
---

# LLM inline image preflight

[2026-06-10 / 15:43:05 KST] Codex added image payload preflight to the shared `callGemini()` multimodal entrypoint.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@8965d46`
- New commit: `f6b9584 fix(llm): preflight inline image payloads`
- Current branch delta: 19 commits ahead of `origin/main`
- Online push: not performed

## Scope

- `src/lib/llm/gemini.ts`
  - Normalizes inline image MIME and base64 whitespace.
  - Rejects unsupported image MIME before proxy/direct SDK egress.
  - Rejects empty, oversized, malformed, non-image, truncated, and MIME-mismatched image data.
  - Keeps crisis routing before image validation so red-zone user input still short-circuits correctly.
- `src/lib/llm/__tests__/gemini.test.ts`
  - Uses a real PNG signature for direct/Vertex multimodal wiring.
  - Covers invalid base64, syntactically valid non-image base64, unsupported MIME, and oversized image rejection before SDK/audit calls.

## Verification

- PASS: `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (9 tests; expected audit-failure warning from the existing audit test).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:constraints`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan.

No direct edit to `C:\Coding\2ndB`.
