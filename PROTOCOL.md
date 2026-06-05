# PROTOCOL.md — 3-AI 공용 통신 프로토콜

> **목적**: Claude · Codex · Antigravity(Gemini) 세 AI가 같은 머신·레포에서 동시에 일하면서, **파일(md) + git**만으로 충돌 없이 요청·결과·상태를 주고받는다. 모든 메시지는 git에 PR처럼 누적된다.
> **이 파일은 세 AI 모두의 운영 원칙(헌법)이다. 세션 시작 시 반드시 읽는다.**

---

## 0. 역할 (자세한 분장은 `ROUTING.md`)
- **Claude** = 메인 지시 AI(오케스트레이터) + **코딩**. 사용자와 직접 대화하고, 작업을 분해해 Codex·Antigravity에 분배하고, 결과를 통합한다. **마스터 보드(`BOARD.md`)의 유일한 작성자.**
- **Codex** = **이미지 · UI/UX**. 디자인·비주얼·레이아웃·UX 플로우.
- **Antigravity(Gemini)** = **안드로이드 네이티브 검수**. 네이티브 빌드 검증·디바이스 QA·성능/크래시 점검.
- **Grok** = **X(소셜) 트렌드·소비자 리서치**. 추가·변경 결정 전에 X(트위터) 등에서 글로벌 소비자 취향·반응을 검색·분석해 인사이트 제공(코딩·디자인·QA는 안 함).

---

## 1. 황금 규칙 — Single-Writer (충돌 방지의 핵심)
> **각 AI는 자기 소유 파일에만 쓴다. 남의 파일은 읽기만 한다.** 이것만 지키면 세 AI가 동시에 커밋해도 git 병합 충돌이 나지 않는다.

| 파일/폴더 | 작성자(쓰기) | 나머지(읽기) |
|---|---|---|
| `BOARD.md` | **Claude만** | Codex·Antigravity |
| `agents/claude/**` | Claude만 | 모두 |
| `agents/codex/**` | Codex만 | 모두 |
| `agents/antigravity/**` | Antigravity만 | 모두 |
| `agents/grok/**` | Grok만 | 모두 |
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
  3. 머지 후 **라이브 화면**을 사용자에게 제공.
- **라이브 화면 수단** (2nd-B = Expo ~56 / RN managed, 클론 `E:\2ndB`):
  - **빠른 UI 확인 (기본)**: `npm run web`(`expo start --web`) → 로컬 웹 → 스크린샷. 가장 빠름, 에뮬 불필요.
  - **네이티브 확인**: `npx expo run:android` → prebuild + 에뮬레이터(AVD `Pixel_9_Pro_XL`) 실행 → 스크린샷. **Antigravity(네이티브 검수) 위임 가능**, Claude가 전달.
  - **계정·데이터 작업 (옵션 1)**: `vercel.json` + Supabase 기존 구성 → Vercel 배포 URL로 제공.
- **머지 전 품질 게이트**: `npm run verify` (lint+type-check+i18n+lexicon+llm-boundary+constraints+no-emdash+jest) 통과 필수.
- **환경(준비됨)**: node v24 · npm 11 · node_modules 설치됨 · Android SDK/Studio/JDK17 · AVD `Pixel_9_Pro_XL`.
- **주의**: `main` 머지는 공유 레포에 영향 → 머지 전 `git fetch` + 충돌 점검. 머지 직전 사용자에게 한 줄 고지.
- 사이클 중간 산출물은 라이브로 올리지 않는다(브랜치/PR 링크로만 공유).

---

## 9. 작업 출처 불문 — 항상 허브에 브로드캐스트 (CRITICAL)
> 누가 시켰든 — **Claude 분배 / 사용자 직접 지시 / 자가 발의** — 작업하면 허브에 남긴다. 그래야 "누가 뭘 하는지" 전원이 본다.

- **작업 시작 시**: 내 `STATUS.md` 갱신 — 현재 작업 + **출처**(`src: claude` | `src: user` | `src: self`). 다른 AI가 알아야 할 일이면 `agents/<me>/outbox/`에 `type: fyi` 메시지로 브로드캐스트.
- **작업 완료 시**: outbox에 결과(`response` 또는 `fyi`) + `STATUS.md` 갱신.
- **예시**: 사용자가 Codex에 디자인을 **직접** 지시 → Codex는 `STATUS.md`에 `src: user — 로그인 디자인 작업중` 기록 + (영향 있으면) `fyi`로 알림 → 완료 시 outbox에 deliverable.
- **Claude(오케스트레이터)**: 세션마다 각 `STATUS.md` + 모든 outbox를 읽어 `BOARD.md`에 반영(BOARD 단일 작성자 유지). 그래서 **사용자-직접 작업도 BOARD에 모인다.**
- **철칙**: 허브에 없는 작업 = 다른 AI에겐 *존재하지 않는* 작업. 조용히 혼자 일하지 말 것.

---

## 10. 실행 모드 & 협업 운영 (4-AI 동시 가동)
> 이 절은 4-AI가 같은 머신에서 **동시·병렬·자동**으로 돌 때의 운영 규칙이다.

### 10.1 권한·실행 모드 (자동승인)
각 AI는 헤드리스/대화형 모두 **자동승인 모드**로 가동한다. CLI별 등가 플래그:

| AI | 자동승인 플래그 |
|---|---|
| Claude | `bypassPermissions` (대화형, 사용자와 직접 소통) |
| Codex | `-s danger-full-access` |
| Gemini(Antigravity) | `-y` / `--approval-mode yolo` |
| Grok | `--always-approve` |
| Antigravity(agy) | `--dangerously-skip-permissions` (1회 OAuth 인증 후) |

- **예외 — 자동승인이어도 항상 사용자 확인**: ① 파괴적 작업(force-push·`reset --hard`·DROP·대량 삭제) ② 비용 발생(결제·API 폭증) ③ secrets/credentials 수정·전송.
- 대화형으로 띄울 때 필요한 OS 권한(Windows cmd/PowerShell · 화면제어(computer use) · Chrome · Android Studio/에뮬 등)은 **세션 초반 1회 일괄** 사용자에게 요청한다.

### 10.2 대화 채널 — Claude 단독 대면
- **Claude만 사용자와 실시간 대화**하며 작업을 지휘한다. Codex·Antigravity·Grok은 **백그라운드에서 Claude의 지시를 수행**하고 결과를 허브에 남긴다.
- 단, 사용자가 특정 AI의 **터미널을 직접 띄워** 대화하면 그 세션에선 사용자와 직접 소통한다(§10.4).

### 10.3 병렬 기본
- **맥락이 침해되지 않는 한 모든 작업은 최대한 병렬**로 진행한다(독립 작업 동시 실행). 의존성 있는 작업만 직렬. 공유 git 커밋은 `pull --ff-only` 후 작은 단위로.

### 10.4 사용자 직접 지시 / 현황 질의 (상시)
- 사용자는 **언제든** 특정 AI에게 직접 작업을 지시하거나 진행현황을 물을 수 있다.
- **직접 지시 받으면**: 즉시 `STATUS.md`에 `src: user`로 기록하고 착수, 완료 시 outbox에 결과(§9). 조용히 혼자 하지 말 것.
- **현황 질문 받으면**: 자기 `STATUS.md` 기준으로 즉답. (전체 현황은 Claude가 `BOARD.md`로 답한다.)

### 10.5 코드 변경 게이트 (재확인)
- 코드 수정이 필요한 AI는 **별도 브랜치/worktree에서 작업** → 변경·리뷰 내용을 Claude에 공유(outbox `request`/`response`) → **Claude가 검토**하고, 필요하면 Claude가 직접 수정·보완한 뒤 → **머지**(§4 작업사이클 · §8 라이브 검증 게이트). force-push·history 재작성 금지.

### 10.6 산출물 = HTML 리포트 (전 AI, CLAUDE.md §13)
- **Codex·Grok·Antigravity 모두** 리포트·스펙·리서치·감사 등 *사람이 읽고 판단할 산출물*은 **self-contained HTML**로도 작성하고 `start "" "<경로>"`로 기본 브라우저에 띄운다. 저장: `agents/<me>/outbox/preview/<YYYYMMDD-HHMMSS>-<slug>.html` (다크·군더더기 없음, 색 3개 이내, 이모지/장식 금지 — AI slop 방지).
- 단 **허브 outbox `.md`는 기계판독용 기록으로 유지**(Claude가 파싱·종합). 즉 **HTML(사람용) + md(허브 기록) 병행**, 메시지 `## Links`에 HTML 경로 포함.
- 이미지 산출물은 Codex `onboarding §2-3`(썸네일 갤러리) 규칙을 따른다.

### 10.7 리포트 → 즉시 develop-able 분배 (오케스트레이터)
- Claude는 어떤 AI의 리포트/응답을 받으면 **반드시 다음 develop-able(실행 가능한) 작업을 즉시 분배**한다. AI를 유휴로 두지 않는다(continuous pipeline). 리포트는 "수거하고 끝"이 아니라 항상 다음 액션으로 전환한다.
- 발견·권고는 구체적 후속 작업으로 만들어 같은(또는 적합한) AI에 재분배. 막히면 Simon 결정 항목으로 분리. 각 AI 장점 활용(Codex=UI/이미지, Grok=소셜/소비자, Antigravity=Android 검수, Claude=코딩/아키텍처/오케스트레이션).
