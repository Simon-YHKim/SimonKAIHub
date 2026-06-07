# PROTOCOL — agent-hub-lite

The complete rule set. Keep it ~1 page. If it grows past a page, you're over-building.

## 1. Single-writer (the core rule)

Each agent writes **only** inside `agents/<name>/`. Every other file is read-only to it.
`BOARD.md` is written **only** by the orchestrator.

This is the whole conflict-avoidance strategy. Because no two agents ever write the same file, parallel commits never produce merge conflicts on shared state. No locks, no leases, no stale-lock recovery.

## 2. Messages = markdown files

An agent communicates by creating a file in its own `agents/<name>/outbox/`:

```
agents/agent-a/outbox/20260607-101500-to-orchestrator-feature-x-done.md
```

With YAML frontmatter:

```yaml
---
from: agent-a
to: orchestrator        # or "all"
type: result            # request | result | review | fyi | blocker | consensus
ref: <optional id of a message this replies to>
status: open            # open | done
---
```

Body: what you did / what you need / links to branches, PRs, screenshots. **Link artifacts; don't paste large code into the hub.**

Never edit someone else's message. Reply with a new file in your own outbox.

## 3. Inbox is a query, not a folder

There is no `inbox/` directory anyone writes to. Your inbox is *computed*: messages across all `agents/*/outbox/` where `to: <you>` (or `to: all`) and `status: open`. `tools/board.sh` / `tools/board.ps1` runs this query.

## 4. The cycle

```
0. Read CONTROL.md. If state is `paused`/`draining`: finish the current item, write STATUS, stop.
1. Read BOARD.md + your inbox (board.sh).
2. Pick ONE highest-value item in your lane.
3. Do the work. Link evidence.
4. Write the result to your outbox (frontmatter as §2).
5. Update agents/<you>/STATUS.md. Commit (your files only).
6. (Optional) wait an interval, then back to 0.
```

## 5. git rules (safe concurrency)

- `git pull --ff-only` before work.
- Stage **your files only** — `git add agents/<you>/ ...` explicitly. Never `git add -A` / `git add .` (it sweeps up others' uncommitted work).
- Never force-push, `reset --hard`, or rewrite history while unmerged submissions exist.
- Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:` …).
- **Online push / PR / merge to the shared remote = orchestrator only.** Workers commit locally (or to their own branch) and submit via outbox.

## 6. CONTROL semaphore (pause / kill-switch)

`CONTROL.md` has one field that the orchestrator owns:

```yaml
state: running   # running | paused | draining
```

- `running` — normal operation.
- `paused` — every agent finishes its current item, records `state: paused` in its STATUS, and waits. No new items.
- `draining` — finish in-flight work, start nothing new, then idle.

To stop the whole swarm: orchestrator sets `state: paused` and commits. To resume: set `running`. This is also the **kill-switch** — flip to `paused` on any runaway (cost, errors, loops).

## 7. The orchestrator

One agent is the orchestrator. It:
- is the only writer of `BOARD.md` (the single source of truth for overall status),
- collects workers' outbox submissions, reviews them, and integrates/merges,
- is the only one to push to the shared online remote,
- owns `CONTROL.md`.

## 8. Identity (optional, recommended)

Commit as yourself so `git log` shows who did what:
`git -c user.name=<name> -c user.email=<name>@hub.local commit ...`

## 9. Don't

- Write outside `agents/<you>/` (orchestrator: outside its files + BOARD/CONTROL).
- `git add -A`. Force-push. Edit others' messages.
- Inject instructions for other agents into shared files (PROTOCOL/BOARD). Put requests in your outbox.
- Paste secrets/PII into any file.

---

That's the entire protocol. The cleverness is in what's **absent**: no server, no DB, no lock manager — just directory ownership + one semaphore file.
