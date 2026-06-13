# BACKLOG.md — Cross-Domain Improvement Backlog

> Synthesized from a 4-domain adversarial audit (2nd-B fn/ux, hub, skills, stack) via Workflow `wnc60iphn` (11 agents). Only REAL/sharpened findings retained. Deduped, ranked by leverage. Within each tier, Claude-autonomous items lead. Claude's /loop chews this queue.
> Generated 2026-06-14. Owner: claude (merge gate).

## Status legend
`[ ]` todo · `[~]` in progress · `[x]` done · `[-]` dismissed (with reason)

---

## P0 — Correctness / Safety / Blocks-Autonomy

### Claude-autonomous (do in loop)
- `[x]` **commit.ps1 index.lock retry** — landed (concurrent-writer safety). + **mutex + `exit 1` on failure** (retry alone still races; failed commit must not look fresh). `tools/commit.ps1`
- `[ ]` **No per-AI-invocation timeout** — one hung CLI stalls the sequential daemon cycle forever. Wrap each CLI in `Start-Job`+`Wait-Job -Timeout`; on timeout kill + log TIMEOUT + continue. `tools/hub-daemon.ps1` Invoke-AI/loop. (S)
- `[ ]` **Set-Heartbeat fakes freshness + violates single-writer + reverts paused** — daemon writes other AIs' STATUS, forces `state: running`, masks a `paused` hub. Fix: stop writing STATUS; age daemon-AIs by `tools/live/<ai>.log` mtime in monitor.ps1; only when CONTROL.state==running. (S)
- `[ ]` **Crash-restart / liveness supervision** — monitor DAEMON-green is a stale-log illusion; verify a live PID + next-cycle-due, not just log mtime. (S–M)
- `[ ]` **Destructive-action PreToolUse hook + permissions.deny** under intentional `bypassPermissions` — hard-block `rm -rf`/`reset --hard`/`push -f`/`--no-verify`/`DROP TABLE` + writes to `.env*`/`credentials*`. Encodes §6/§11-5 in the harness. (S)

### Needs a runtime owner (Claude sets up)
- `[ ]` **Durable scheduler (SPOF)** — whole loop dies when the Claude session closes. `Register-ScheduledTask` (AtLogOn + restart), gated on CONTROL.state, PID lockfile keyed on AI-set so the 300s codex/grok + 1800s AG loops coexist but identical sets can't stack. (S)

---

## P1 — High-Leverage

### 2nd-B core product loop (Claude coding; coordinate with codex)
- `[ ]` **Stale core-loop screens after capture (no shared data/cache) — COUPLED with NavGraph rebuild.** Fixed order: (a) stabilize `dataNodes` ref (id-set/content hash); (b) `React.memo` NavGraph w/ node-id comparator; THEN (c) focus-refetch across index/records/core-brain/insights/trinity/record[id]. Don't ship (c) alone. `src/app/index.tsx`, `NavGraph.tsx`. (M)
- `[ ]` **NavGraph (2689 ln) rebuilds all animation loops on every data-identity change** — same fix as above (memo upstream array). `useNativeDriver:false` at NavGraph:950. (M)
- `[ ]` **Capture = 2 serial, un-abortable, double-billed LLM calls** — thread one AbortController keyed to focus/unmount; evaluate collapsing classify+ingest into one proxy round-trip. Preserve C3/C9 order. `capture.tsx:793-846`. (M)
- `[ ]` **~13 fire-and-forget audit/crisis writes → silent C3/C9 gaps on Supabase outage** — one `enqueueAuditWrite` (AsyncStorage outbox + flush-on-reconnect); tighten `isProxyCrisisRejection` so unreadable 422 isn't auto-crisis. `lib/llm/gemini.ts`. (S–M)
- `[ ]` **Disabled PremiumButton drops out of focus/press tree + sub-3:1 disabled contrast** — keep Pressable w/ `disabled`, raise BTN_DISABLED_FG ≥3:1, add accessibilityHint. `surfaces.tsx:163-165,258-271`. (S)
- `[ ]` **Home CTAs bypass design system (no press feedback, dup visuals)** — use PremiumButton/PremiumCTA; shared pressable w/ 80ms opacity-0.8 feedback. `index.tsx:522-675`. (M)

### Hub autonomy charter (Claude)
- `[ ]` **No merge-gate backpressure** — §12.2 "8 unmerged" is prose-only. Before discovery, count AI's open outbox items; if ≥8, skip discovery + dispatch throttle-redirect; cap worktrees/AI. `hub-daemon.ps1`. (M)
- `[ ]` **AG lane = gemini text seat, not native** — `agy -p` confirmed non-functional headless (2026-06-14). Either add `agy` branch w/ gemini fallback, OR relabel AG lane honestly in all 3 §19 configs. STATUS already corrected. (S→M)

### Skills/stack hygiene (Claude)
- `[ ]` **§21 routing misses dominant workflows + 3 configs out of sync** — add native-UI/store-submit/LLM-feature/deploy routing rows; re-sync CLAUDE/AGENTS/GEMINI verbatim (§18). (M)
- `[ ]` **Config drift — AGENTS.md/GEMINI.md have no §18; cross-file "§18" pointers break** — renumber ports to canonical scheme; port PreToolUse/HAS_ROUTING content; heading-diff guard. (M)
- `[ ]` **cp949 crash half-fixed** — set `PYTHONUTF8=1` at session start; patch doc one-liners to `encoding='utf-8'`. (S)
- `[ ]` **Hub guardrails prose-only** — extend commit.ps1 (the choke point): reject staged paths outside `agents/<As>/` unless claude; secret-scan staged; flag staged-count vs -Files divergence (de-facto add -A). (M)

---

## P2 — Nice-to-Have
- `[ ]` **Zero integration coverage on records↔sources data-shape contract** — one Supabase-mock round-trip test (createRecord/captureFromMarkdown → mergeEvidence → exportUserWiki field parity). Cheapest high-value win. (M, codex test-only)
- `[ ]` **Profile hub chips 14px caption-only, color-only signal** — add glyph + body(16px) label + muted hint line. `profile.tsx:177-196`. (M)
- `[ ]` **Tab active-state + secondary-button edge contrast unverified post-palette-pivot** — non-color active cue; bump labels; raise `gameboy.border` alpha; re-run contrast matrix. (S→M)
- `[ ]` **Asset version sprawl (~16MB dead weight)** — delete v45/v49 dirs + require maps + variant prop; resolve rhythm_core PLACEHOLDER. CLAUDE.md §20.4. (L)
- `[ ]` **INDEX.md stale vs 5-plugin source-of-truth** — regenerate from manifests + CI drift-guard; verify sibling-repo cutover install actually clones. (M)
- `[ ]` **Hardcoded skill counts contradict across 6 docs** — drop exact counts or CI-generate. (S)
- `[ ]` **Three skill trees diverged (13 orphans, triple-copy spec)** — pick canonical tree. **§35.1 ai-debate decision (source-of-truth = irreversible)** before mechanical migration. (L)

---

## Cross-cutting notes
1. **2nd-B P1 coupling:** stale-screens + NavGraph rebuild are ONE change in fixed order (stabilize array → memo → focus-refetch). Don't ship focus-refetch alone.
2. **Hub monitoring blind spot is systemic:** per-AI-timeout + Set-Heartbeat fake-freshness + stale-log green together let all monitor surfaces show "healthy" while the daemon is hung. Land the PID-liveness probe in the same pass as the heartbeat fix.
3. **Root cause (hub/stack P0s):** critical rules live in markdown prose while enforcement points (scheduled task, deny-list, commit hook) are empty — `design-first-gate.sh` proves the PreToolUse pattern works. Port the highest-risk prose rules into that hook/task layer.
4. **Do NOT re-do:** commit.ps1 retry (landed); the "§28.4 hang" claim (false — preconditions avoided); "bypassPermissions = banned" rhetoric (intentional §18 grant).

## Dismissed / unconfirmed (merge-gate verdicts)
- `[-]` **AG: Sign-in unauthenticated nav (Link) + deep link broken (P1/P2)** — DISMISSED as false positive (2026-06-14, Claude framework-aware). `_layout.tsx:249` renders the full Stack for `!userId` (unauth nav to /manual + /sign-up is allowed by design); Links use standard `Link asChild`+Pressable wiring. AG's headless-gemini emulator interaction is unreliable (tap-miss) and deep-links to genuinely auth-gated routes bouncing to /sign-in is the intended auth model, not a bug. Re-open only if a real interactive emulator session reproduces a dead /manual link.
