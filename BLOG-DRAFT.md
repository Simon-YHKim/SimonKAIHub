# The layer after git-worktrees: a server-less message bus for your AI coding agents

*Draft. Two languages below — English first, 한국어 second. This is a write-up of a working personal setup, extracted into a ~10-file template ([agent-hub-lite](./README.md)).*

---

## EN

### Everyone stopped at the same place

If you run more than one AI coding CLI, you've probably found the same pattern everyone else did: **git worktrees**. Claude Code ships a `worktree` flag; Claude Squad and Conductor wrap tmux + worktrees around multiple CLIs; the official docs bless "2–3 agents on separate worktrees." It works. Each agent gets an isolated checkout, and a human merges the branches.

But notice what's missing: **the agents can't talk to each other.** They're parallel, not collaborative. There's no handoff, no shared status, no "pause everything." Worktrees solved isolation and stopped there.

### The next layer: let them leave each other notes

The idea is almost embarrassingly simple. Give the agents a shared git repo and three rules:

1. **Each agent writes only to its own directory** (`agents/<name>/`). Nothing else. Ever.
2. **Messages are markdown files** with `to:/from:/type:/status:` frontmatter, dropped in your own `outbox/`.
3. **One file (`CONTROL.md`) is a global switch**: `running` / `paused` / `draining`.

That's it. No server. No database. No message broker. Just files and `git commit`.

### Why this is more robust than it looks

The clever part is **rule #1**. Most agent-messaging systems (the closest being [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail)) prevent conflicts with **file locks or leases** — agent A leases `foo.ts` for 5 minutes, agent B waits. Locks bring their own pain: stale locks, TTL tuning, cleanup logic.

Directory single-writer sidesteps all of it. If no two agents ever write the same file, **there is nothing to lock.** Parallel commits can't conflict on shared state because there *is* no shared writable state — only each agent's own folder, plus an orchestrator-owned board. Conflict avoidance becomes a *structural property*, not a runtime mechanism.

The second nice piece is **`CONTROL.md` as a swarm-wide pause/kill-switch.** Every agent reads `state:` at the top of its loop. Flip it to `paused`, commit, and the whole swarm winds down at the next cycle. It doubles as a cost/error kill-switch. A single global pause primitive is surprisingly rare in agent frameworks — they tend to model per-task locks, not a master stop.

### What it looks like

```
PROTOCOL.md     # the rules (1 page)
CONTROL.md      # running | paused | draining
BOARD.md        # orchestrator-owned status
agents/<name>/
  STATUS.md
  outbox/*.md   # messages: to:/from:/type:/status:
tools/board.sh|ps1   # "inbox" = grep over everyone's outbox
```

Your inbox isn't a folder — it's a *query*: open messages addressed to you across all outboxes. One small script computes it.

### Where it fits vs the tools you know

| | isolation | inter-agent comms | global pause | server/DB | multi-vendor |
|---|---|---|---|---|---|
| Claude Code worktrees / Agent Teams | ✅ | partial (Teams: in-process) | — | no | single-vendor |
| Claude Squad / Conductor | ✅ (tmux+worktree) | ❌ | ❌ | no | ✅ |
| mcp_agent_mail | (your branches) | ✅ (file-lease) | ❌ | MCP + SQLite | ✅ |
| **agent-hub-lite** | your branches | ✅ (md files) | ✅ (CONTROL) | **none** | ✅ |

### Honest limits (read these before you copy it)

- **The bottleneck is review, not generation.** Five agents producing in parallel still funnel into one reviewer. If you can't review and merge that fast, you're just growing a backlog. Keep concurrent agents to what *you* can absorb.
- **Small projects may not have enough independent work** to justify a bus. If there aren't real parallel workstreams, worktrees alone are simpler.
- **Native features are catching up.** If you're single-vendor (all Claude), evaluate Agent Teams first — in-process peer messaging may cover most of this.
- **This is a rare assembly, not an invention.** Every piece exists elsewhere; the value is the specific, light combination. Credit to mcp_agent_mail.

### Try it

Clone the template, define an `agents/<name>/` per CLI, paste the activation prompt into each terminal, and run `board.sh`. Five minutes. Then ask yourself the honest question: do I have enough genuinely-parallel work to feed it? If yes, it's a quiet, transparent, vendor-neutral way to make your agents a team instead of a crowd.

---

## 한국어

### 다들 같은 데서 멈췄다

AI 코딩 CLI를 둘 이상 돌려봤다면 누구나 도달하는 지점이 있다 — **git worktree**. Claude Code엔 worktree 플래그가 있고, Claude Squad·Conductor는 tmux+worktree로 여러 CLI를 감싼다. 잘 작동한다. 각 에이전트가 격리된 체크아웃을 갖고, 사람이 브랜치를 머지한다.

그런데 빠진 게 있다. **에이전트끼리 대화를 못 한다.** 병렬일 뿐 협업이 아니다. 핸드오프도, 공유 상태도, "전체 멈춤"도 없다. worktree는 격리만 풀고 거기서 멈췄다.

### 다음 레이어: 서로에게 쪽지를 남기게 하라

아이디어는 민망할 만큼 단순하다. 공유 git 레포 + 규칙 셋:

1. **각 에이전트는 자기 디렉토리(`agents/<name>/`)에만 쓴다.** 그 외엔 절대 안 쓴다.
2. **메시지는 md 파일** — `to:/from:/type:/status:` frontmatter를 자기 `outbox/`에 떨군다.
3. **`CONTROL.md` 한 파일이 글로벌 스위치** — `running/paused/draining`.

끝. 서버도, DB도, 메시지 브로커도 없다. 파일과 `git commit`뿐.

### 왜 보기보다 견고한가

핵심은 **규칙 #1**. 대부분의 에이전트 메시징(최근접 = [mcp_agent_mail](https://github.com/Dicklesworthstone/mcp_agent_mail))은 **파일 잠금/리스**로 충돌을 막는다 — A가 `foo.ts`를 5분 임대, B는 대기. 잠금엔 stale lock·TTL 튜닝·정리 로직이 따라온다.

디렉토리 single-writer는 그걸 통째로 우회한다. **두 에이전트가 같은 파일을 안 쓰면 잠글 게 없다.** 공유 쓰기 상태 자체가 없으니(각자 폴더 + 오케스트레이터 보드뿐) 병렬 커밋이 충돌할 수 없다. 충돌 회피가 런타임 메커니즘이 아니라 **구조적 성질**이 된다.

두 번째는 **`CONTROL.md` = 스웜 전체 일시정지/킬스위치.** 모든 에이전트가 루프 맨 앞에서 `state:`를 읽는다. `paused`로 바꿔 커밋하면 다음 사이클에 전부 멈춘다. 비용·오류 폭주 시 킬스위치로도 쓴다. 글로벌 정지 프리미티브는 의외로 드물다 — 대개 작업별 락만 다루지 마스터 정지는 없다.

### 알아야 할 한계 (복사 전에 읽어라)

- **병목은 생성이 아니라 검증이다.** 5개가 병렬로 뽑아도 리뷰어는 하나다. 그 속도로 못 머지하면 백로그만 쌓인다. 동시 에이전트는 *내가* 흡수 가능한 만큼만.
- **작은 프로젝트엔 병렬 작업이 부족할 수 있다.** 진짜 독립 워크스트림이 없으면 worktree만으로 충분하다.
- **네이티브 기능이 따라온다.** 단일 벤더(전부 Claude)면 Agent Teams를 먼저 보라.
- **발명이 아니라 드문 조립이다.** 모든 조각은 다른 데 있다. 가치는 가볍고 특정한 조합. mcp_agent_mail에 크레딧.

### 해보기

템플릿 클론 → CLI별 `agents/<name>/` 생성 → 각 터미널에 활성화 프롬프트 → `board.sh`. 5분. 그리고 정직하게 물어라: 먹일 만큼 병렬 작업이 있나? 있다면, 조용하고 투명하고 벤더 중립적인 방식으로 에이전트를 군중이 아니라 팀으로 만든다.
