---
from: codex
to: claude
type: handoff
priority: P0
topic: main graph reference component review
created: 2026-06-08 03:39:04 KST
app_worktree: E:\Coding Infra\_worktrees\2ndB-codex
branch: codex/core-label-tail-cleanup
app_commit: 1f1e7f4
---

# Main Graph Reference Component Review

[2026-06-08 / 03:39:04 KST]
#comm #codex #claude-handoff #2nd-B #ui-ux #graph #art #verify-pass

## Summary
- Implemented Codex lane for `agents/claude/outbox/20260608-codex-ag-main-graph-reference-doublecheck.md`.
- App commit: `1f1e7f4 fix(graph): align data nodes and links with reference`.
- Scope is limited to NavGraph art/component behavior and Pattern Link styling.
- No push/PR by Codex.

## What Changed
- `src/components/graph/NavGraph.tsx`
  - Increased graph node drawing sizes so the live graph reads closer to Simon refs: Soul Core `112`, Pattern Core `58`, tier-3 `46`, Pattern Data `42`.
  - Swapped real tier-4 saved-piece nodes from `FinalLogArtV49` to `FinalPatternDataArtV49`.
  - Tier-4 Pattern Data now keeps color-key classification via `resolvePatternDataColor`, using title/summary/tags/domain id.
  - Centered tier-4 hit/art wrappers on the new `DATA_NODE_SIZE`.
  - Rounded Pattern Link strokes and strengthened active/flow/highlight widths.
- `src/lib/graph/pattern-link.ts`
  - Raised default link width/opacity/saturation range from thin ambient lines to thicker conduit-like links:
    - width `1..3` -> `2..5`
    - opacity `0.18..0.95` -> `0.3..1`
    - saturation floor `0.35` -> `0.5`
- `src/lib/graph/__tests__/pattern-link.test.ts`
  - Updated regression expectations for the new Pattern Link bounds.

## Reference Fit
- Ref images read as crystal objects, not dot/log markers. Current live components already have v10 crystal core assets, so the main mismatch was size/readability plus tier-4 using logbook art.
- This pass makes the saved data nodes visually align with the small blue/pattern-data crystal language in both Simon references.
- The stronger rounded Pattern Link styling better matches the glowing conduit feel in the refs without wiring the unused standalone `PatternLink` tile component into the live SVG layer.

## Verification
- Targeted first: `npm test -- --ci pattern-link depth-style tier-visibility world-layout` PASS, 4 suites / 33 tests.
- Targeted first: `npm run type-check` PASS.
- Final: `npm run verify` PASS.
  - lint PASS
  - type-check PASS
  - i18n/lexicon/LLM-boundary/constraints/emdash checks PASS
  - Jest PASS, 98 suites / 859 tests
- `git diff --check` PASS before commit.
- Secret scan on changed files: no secret addition. Only false positive was import path text `theme/tokens`.

## Visual QA Notes
- Expo web was started from Codex worktree on `http://localhost:19007` with `EXPO_PUBLIC_USE_V3_ART=true`; bundle completed.
- Browser MCP backends `iab` and `chrome` were unavailable in this session.
- Headless Edge screenshots worked, but unauthenticated root redirects to `/sign-in`, so Codex could only confirm the auth gate render, not NavGraph itself, without using credentials or session state.
- AG's signed device render lane should perform the final visual comparison against:
  - `agents/claude/refs/main-graph-reference-20260608.png`
  - `agents/claude/refs/main-graph-reference2-drilldown-20260608.png`

## Remaining Design Gap
- The refs show bottom insight cards with `Touch!` CTA always visible. Current product behavior still uses selection-driven sheets/cards rather than persistent bottom cards on the default graph.
- I did not add a new persistent bottom-card IA because it changes interaction hierarchy/state ownership beyond the art-component lane. Recommend Claude decide after AG device render whether this is a required scope item.

