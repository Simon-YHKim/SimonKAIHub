# PROTOCOL.md — 3-AI 공용 통신 프로토콜

> **목적**: Claude · Codex · Antigravity(Gemini) 세 AI가 같은 머신·레포에서 동시에 일하면서, **파일(md) + git**만으로 충돌 없이 요청·결과·상태를 주고받는다. 모든 메시지는 git에 PR처럼 누적된다.
> **이 파일은 세 AI 모두의 운영 원칙(헌법)이다. 세션 시작 시 반드시 읽는다.**

---

## 0. 역할 (자세한 분장은 `ROUTING.md`)
- **Claude** = 메인 지시 AI(오케스트레이터) + **코딩**. 사용자와 직접 대화하고, 작업을 분해해 Codex·Antigravity에 분배하고, 결과를 통합한다. **마스터 보드(`BOARD.md`)의 유일한 작성자.**
- **Codex** = **이미지 · UI/UX**. 디자인·비주얼·레이아웃·UX 플로우.
- **Antigravity(Gemini)** = **안드로이드 네이티브 검수**. 네이티브 빌드 검증·디바이스 QA·성능/크래시 점검.

---

## 1. 황금 규칙 — Single-Writer (충돌 방지의 핵심)
> **각 AI는 자기 소유 파일에만 쓴다. 남의 파일은 읽기만 한다.** 이것만 지키면 세 AI가 동시에 커밋해도 git 병합 충돌이 나지 않는다.

| 파일/폴더 | 작성자(쓰기) | 나머지(읽기) |
|---|---|---|
| `BOARD.md` | **Claude만** | Codex·Antigravity |
| `agents/claude/**` | Claude만 | 모두 |
| `agents/codex/**` | Codex만 | 모두 |
| `agents/antigravity/**` | Antigravity만 | 모두 |
| `PROTOCOL.md` `ROUTING.md` `README.md` | Claude(합의 후) | 모두 |
| `projects/<name>/**` | 해당 작업 담당 AI만 | 모두 |

남의 STATUS나 메시지를 고치고 싶으면 → **고치지 말고, 내 outbox에 응답 메시지를 새로 쓴다.**

---

## 2. 메시지 = 개별 md 파일 (PR처럼 누적)
요청·응답·공지는 **각자 자기 `outbox/`에 하나의 파일**로 만든다. 파일명은 절대 겹치지 않는다(자기 폴더 + 타임스탬프).

### 파일명 규칙
```
agents/<from>/outbox/<YYYYMMDD-HHMMSS>-to-<to>-<slug>.md
예) agents/claude/outbox/20260605-152234-to-codex-login-screen-ui.md
응답은 re- 접두:
예) agents/codex/outbox/20260605-160210-re-login-screen-ui.md
```
시각은 추정 금지, 실제 실행: PowerShell `Get-Date -Format 'yyyyMMdd-HHmmss'` (KST).

### 메시지 frontmatter (필수)
```yaml
---
id: 20260605-152234-claude-to-codex-login-screen-ui
from: claude            # claude | codex | antigravity
to: codex               # claude | codex | antigravity | all
type: request           # request | response | fyi | blocker
ref: ""                 # (응답일 때) 답하는 요청의 id
project: ""             # projects/<name> 중 하나 (해당 시)
priority: normal        # low | normal | high
status: open            # open | done  (요청 발신자가 open으로, 응답 발신자가 done으로)
created: 2026-06-05 15:22:34 KST
---
```

### 본문 섹션 (권장 틀)
- **## Context** — 왜/배경 (1~3줄)
- **## Ask** (요청) 또는 **## Deliverable** (응답) — 구체적으로 무엇을
- **## Acceptance** — 완료 기준(체크리스트)
- **## Links** — 관련 파일 경로·커밋·스크린샷 경로

---

## 3. Inbox = 계산되는 것 (폴더가 아님)
"내 받은편지함"은 별도 폴더가 아니라 **쿼리**다:
> `agents/*/outbox/` 안의 메시지 중 `to == 나` 이고, 아직 내가 `ref`로 응답하지 않은 것.

세션 시작 루틴:
1. `git pull --ff-only` (최신화)
2. `BOARD.md` 읽기 (현재 전체 상태)
3. 내 inbox 스캔 → `to: <나>` & `status: open` & 미응답 메시지 처리
4. 작업 후 내 outbox에 응답 + 내 `STATUS.md` 갱신 → 커밋 → push

---

## 4. 작업 사이클 (PR-like)
```
사용자 → Claude(요청)
   Claude: 작업 분해 → BOARD.md 갱신 + agents/claude/outbox/ 에 분배 메시지(request) 작성 → commit/push
      Codex/Antigravity: pull → inbox 확인 → 작업 → agents/<me>/outbox/ 에 응답(response, status:done) + STATUS 갱신 → commit/push
   Claude: pull → 응답 수거 → 통합 → BOARD.md 항목 done 처리 → commit/push → 사용자에게 보고
```

---

## 5. git 규칙 (동시 작업 안전)
- 커밋 단위는 작게, **Conventional Commits**: `feat(comm): request codex — login UI`, `chore(comm): codex status update`, `docs(comm): response — native QA pass`.
- **항상 `pull --ff-only` 후 작업·push.** `--no-ff` 머지/`reset --hard`/force-push **금지**.
- 충돌이 났다면 = single-writer 규칙을 누군가 어긴 것. 멈추고 사용자에게 보고.
- 커밋 트레일러는 각 AI 식별: `Co-Authored-By: <agent>`.

---

## 6. 상태 값 정의
| status | 의미 |
|---|---|
| `open` | 요청됨, 아직 응답 없음 |
| `done` | 응답 완료(deliverable 제공) |
| (BOARD의) `blocked` | 의존성·결정 대기 — Claude가 BOARD에 표기 |

`type: blocker` 메시지는 즉시성 높음 — 받은 AI는 다른 작업보다 우선 확인.

---

## 7. 금지
- 남의 소유 파일 수정(§1 위반).
- 자기 lane 밖 작업을 무단 수행(분장은 ROUTING.md) — 필요하면 담당 AI에게 `request`.
- force-push·history 재작성·대량 파일 일괄 덮어쓰기.
- 비밀키·credentials·PII를 메시지/보드에 평문 기재(경로·참조로만).

---

## 8. 라이브 검증 사이클 (Live-Check Cycle)
> 평상시(사이클 중간)엔 **로컬 허브 조율 + 브랜치 작업**만 한다. 사용자에게 라이브 화면을 보여주는 건 **대단위 작업 사이클의 게이트에서만**.

- **언제**: 한 대단위 작업 사이클이 끝나 **사용자의 라이브 화면 확인이 필요할 때**.
- **절차 (Claude가 실행)**:
  1. 사이클 결과를 `2nd-B`에 **push**.
  2. **PR로 `main`에 merge** (force-push 금지, 항상 PR 경유, 다른 AI 브랜치와 충돌 점검 후).
  3. 머지 후의 **라이브 화면**(배포 URL / 실행 화면 / 스크린샷)을 사용자에게 제공.
- **주의**: `main` 머지는 공유 레포에 영향 → 머지 전 `git fetch` + 충돌 점검. 머지 직전 사용자에게 한 줄 고지.
- 사이클 중간 산출물은 라이브로 올리지 않는다(브랜치/PR 링크로만 공유).
