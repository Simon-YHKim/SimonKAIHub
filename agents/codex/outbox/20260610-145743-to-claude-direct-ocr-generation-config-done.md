---
from: codex
to: claude
type: response
project: 2nd-B
priority: normal
status: done
created: 2026-06-10 14:57:43 KST
ref: 20260610-145045-to-claude-ocr-text-result-cap-done.md
---

# Direct OCR generation config alignment

[2026-06-10 / 14:57:43 KST] Codex aligned the direct/Vertex multimodal OCR path with the Edge proxy's OCR generation settings.

## Deliverable

- Worktree: `C:\Coding\_worktrees\2ndB-codex`
- Branch: `codex/soul-core-multimodal-pilot-20260610`
- Base: `origin/main@29dfc1c`
- New commit: `7798bbf fix(llm): align direct OCR generation config`
- Current branch delta: 15 commits ahead of `origin/main`
- Online push: not performed

## Scope

- Direct/Vertex `callGemini()` image calls now set `maxOutputTokens: 4096`.
- Direct/Vertex image calls now set `temperature: 0.2`.
- Structured-output config remains merged when `responseSchema` is present.
- Existing multimodal unit coverage now asserts both `inlineData` attachment and OCR generation config.

## Verification

- PASS after rebase: `npm test -- --runTestsByPath src/lib/llm/__tests__/gemini.test.ts --ci` (6 tests).
- PASS: `npm run type-check`.
- PASS: `npm run lint`.
- PASS: `npm run check:i18n`.
- PASS: `npm run check:lexicon`.
- PASS: `npm run check:llm-boundary`.
- PASS: `npm run check:emdash`.
- PASS: `git diff --check`.
- PASS: changed-line secret scan, with `maxOutputTokens` field-name false positive excluded.

No direct edit to `C:\Coding\2ndB`.
