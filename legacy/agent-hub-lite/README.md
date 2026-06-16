# agent-hub-lite

> A **server-less, git-native message bus** for coordinating multiple AI coding CLIs in one repo.
> The layer *after* git-worktrees: agents that actually talk to each other — through plain markdown files.

**Status:** draft template (extracted from a working personal system). Not a framework, not a product — a ~10-file pattern you can copy and run in 5 minutes.

---

## What this is (and isn't)

Most parallel-AI-coding setups (Claude Squad, Conductor, the official `worktree` flag) **isolate** agents into branches and let a human merge. They don't give the agents a way to **communicate, hand off, or be paused as a swarm**.

`agent-hub-lite` adds exactly that, with no server and no database — just files in a git repo:

- **Directory single-writer** — each agent writes *only* to `agents/<name>/`. Merge conflicts on shared files become structurally impossible. (No file-locks, no leases, no stale-lock cleanup.)
- **CONTROL semaphore** — one file (`CONTROL.md`) flips the whole swarm between `running` / `paused` / `draining`. A single global kill-switch.
- **Markdown messages** — agents drop `to:/from:/type:/status:` md files in their own `outbox/`. "Inbox" is a *query* (grep), not a folder anyone writes to.
- **One orchestrator** — a single agent owns the `BOARD.md` status board and (optionally) the only push to the online remote.

It is **not** an invention. This is a *rare assembly* of known ideas. The closest prior art is
[mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) (an MCP "Gmail" for agents, with file-leases + git + SQLite). `agent-hub-lite` is the lighter, server-less cousin: directory-ownership instead of leases, plus a global pause semaphore.

## Why files + git

- **Transparent** — open any file to see the full state. No hidden in-memory queue.
- **Auditable** — every message and status change is a git commit.
- **Vendor-neutral** — works with any CLI that can read/write files and run git: Claude Code, Codex, Gemini CLI, Grok, aider, etc.
- **Crash-safe** — state lives on disk, so a fresh session resumes by reading the files.

## 5-minute setup

```bash
git clone https://github.com/Simon-YHKim/agent-hub-lite my-hub && cd my-hub
# 1. Define your agents (one directory each)
#    agents/orchestrator/ , agents/agent-a/ , agents/agent-b/ ...
# 2. Open each agent in its own terminal (its own CLI), paste its activation prompt.
# 3. Check status any time:
bash tools/board.sh           # macOS/Linux
pwsh tools/board.ps1          # Windows / cross-platform PowerShell
```

Each agent's loop:
```
0. read CONTROL.md  -> if paused/draining, finish current item and stop
1. read BOARD.md + your inbox (tools/board.sh shows messages addressed to you)
2. do ONE unit of work in your lane
3. write result to agents/<you>/outbox/<ts>-<slug>.md  (to:/from:/type:/status:)
4. update agents/<you>/STATUS.md ; commit ; (optional) sleep N ; back to 0
```

### Activation prompt (template)

> You are `<name>` in a file-based agent hub. Read `PROTOCOL.md`, `CONTROL.md`, `BOARD.md` first.
> Single-writer rule: you write ONLY to `agents/<name>/`. Others' files are read-only.
> Each cycle: check CONTROL → read your inbox (`tools/board.sh`) → do one unit → write to your `outbox/` → update STATUS → commit. Stop when CONTROL is `paused`.

## Roles

| Role | Owns | Notes |
|---|---|---|
| **orchestrator** | `BOARD.md`, online git push, merges | the only writer of the board; single point of integration |
| **worker(s)** | `agents/<name>/` | do work in lane, submit via outbox, never push online |

The orchestrator-only-push rule keeps the shared remote conflict-free. For solo use, the orchestrator can also be the only human-facing agent.

## Honest limits

- **Review is the bottleneck, not generation.** N agents producing in parallel still need someone to review and merge. Keep concurrent agents to what your reviewer can absorb (often 1–2).
- **Best for genuinely independent workstreams.** A single small project may not have enough parallel branches to justify a bus.
- **Native vendor features are catching up.** Claude Code's Agent Teams now offers in-process peer messaging; if you're single-vendor, evaluate that first.
- This template is a **snapshot**, not a maintained framework.

## Files

```
PROTOCOL.md          # the rules (single-writer, message format, cycle, pause)
CONTROL.md           # run-state semaphore (running/paused/draining)
BOARD.md             # orchestrator-owned status board
agents/<name>/
  STATUS.md          # this agent's current state
  outbox/            # this agent's messages (md, frontmatter)
tools/board.sh|ps1   # cross-platform inbox + status viewer
BLOG-DRAFT.md        # write-up: "the layer after worktrees"
```

## 한국어 빠른 시작

여러 AI 코딩 CLI(Claude/Codex/Gemini/Grok 등)를 **한 git 레포에서 파일로 협업**시키는 최소 패턴입니다. 서버·DB 없이 md 파일만 씁니다.

- **디렉토리 single-writer**: 각 AI는 `agents/<name>/`에만 씀 → 공유 파일 충돌이 구조적으로 불가능(잠금 불필요).
- **CONTROL 세마포어**: `CONTROL.md` 한 파일로 전체를 `running/paused/draining` 일괄 제어(글로벌 kill-switch).
- **메시지 = md 파일**: 자기 `outbox/`에 `to:/from:/type:/status:` md를 떨굼. inbox는 폴더가 아니라 쿼리(grep).
- **단일 오케스트레이터**: `BOARD.md` 단독 작성 + 온라인 push 단독.

설치: `git clone` → 에이전트별 디렉토리 생성 → 각 CLI 터미널에 활성화 프롬프트 붙여넣기 → `bash tools/board.sh`로 현황 확인.

발명이 아니라 **드문 조립**입니다. 최근접 선례 = mcp_agent_mail(서버형). 이건 서버 없는 경량판.

## License

MIT — see [LICENSE](LICENSE). Credit to [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail) as the closest prior art.
