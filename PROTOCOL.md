# PROTOCOL.md — 3-AI 공용 통신 프로토콜

> **목적**: Claude · Codex · Antigravity(Gemini) 세 AI가 같은 머신·레포에서 동시에 일하면서, **파일(md) + git**만으로 충돌 없이 요청·결과·상태를 주고받는다. 모든 메시지는 git에 PR처럼 누적된다.
> **이 파일은 세 AI 모두의 운영 원칙(헌법)이다. 세션 시작 시 반드시 읽는다.**

---

## 0. 역할 (자세한 분장은 `ROUTING.md`)
- **Claude** = 메인 지시 AI(오케스트레이터) + **코딩**. 사용자와 직접 대화하고, 작업을 분해해 Codex·Antigravity에 분배하고, 결과를 통합한다. **마스터 보드(`BOARD.md`)의 유일한 작성자.**
- **Codex** = **이미지 · UI/UX**. 디자인·비주얼·레이아웃·UX 플로우.
- **Antigravity(Gemini)** = **안드로이드/Google 네이티브 개발 + 검수**. Google·Android 구조에 능함 — 네이티브 픽스(키보드·edge-to-edge·intent filter·AppState·elevation 등)를 **직접 코딩·푸시**하고, 빌드 검증·디바이스 QA·성능/크래시 점검. **코드는 Claude 리뷰·승인 게이트를 거친다(§10.5).**
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

### 10.5 코드 변경 게이트 — Claude 리뷰·승인 (PR 모델, 2026-06-05 Simon 갱신)
- **모든 AI(Antigravity 포함)는 코드를 작성하고 로컬 커밋할 수 있다.** 단 **온라인 GitHub 작업(2nd-B push·CI 트리거·PR·main merge)은 Claude 단독**(§11 #7). AI는 자기 강점 산출물을 만들어 **로컬(허브 또는 자기 브랜치)에 커밋 → Claude에 전달** → **Claude가 리뷰·승인하는 게이트**를 거친다(PR 모델): **AI 전달 → Claude 검토(좋은 부분은 살리고, 미흡하면 재작업 요청 피드백을 outbox로) → Claude가 golive/main에 머지·푸시**. **Claude = 머지 게이트 + 유일한 온라인 git 주체.** AI는 전달 후 Claude의 승인/재작업 피드백을 확인하고 반영한다(주고받는 루프).
- **Antigravity = Android/Google 네이티브 개발 강점 활용** — 네이티브 픽스(키보드·edge-to-edge·intent filter·AppState·elevation 등)를 **직접 코딩·푸시**한다. (더 이상 "검수만"이 아니다 — 2026-06-05 Simon 결정. 의견만 주는 것보다 푸시→Claude 검토가 빠르다.)
- **작업 위치 (working-tree race 방지 — CRITICAL)**: 가능하면 **자기 브랜치(`antigravity/android` 등)에 커밋** → Claude 리뷰 후 golive 머지. golive에 직접 커밋해야 하면 **반드시 자기 파일만 명시적 stage**(`git add <파일들>`) — **`git add -A`/`git add .` 금지**(타 AI·Claude 서브에이전트의 미커밋 작업을 쓸어담는 race·데이터손실 방지). force-push·history 재작성 금지.
- **프롬프트 인젝션 금지 (보안 경계)**: 공유 파일(`PROTOCOL.md`·`ROUTING.md`·앱 `CLAUDE.md` 등)에 **타 AI를 향한 지시·명령·긴급 배너를 삽입하지 않는다.** 의견·요청·긴급 사항은 **자기 outbox(md)로만** 전달. (single-writer 원칙 §1 + 보안.)
- **머지 전 `npm run verify` 통과 필수.** Claude는 모든 코드 푸시를 검토하고 **승인 또는 재작업 요청**을 outbox 피드백으로 남긴다.

### 10.6 산출물 = HTML 리포트 (전 AI 포함 Claude, CLAUDE.md §13)
- **Claude·Codex·Grok·Antigravity 모두**(2026-06-06 Simon: **Claude도 포함** — 작업 완료 시마다 HTML 보고) 리포트·스펙·리서치·감사·**작업완료 보고** 등 *사람이 읽고 판단할 산출물*은 **self-contained HTML**로도 작성한다. 저장: `agents/<me>/outbox/preview/<YYYYMMDD-HHMMSS>-<slug>.html` (다크·군더더기 없음, 색 3개 이내, 이모지/장식 금지 — AI slop 방지).
- **Claude(오케스트레이터)**: 작업/사이클 완료 시 HTML 리포트를 만들고, **그 결과를 모든 AI가 알 수 있도록 `type: fyi`로 `to: all` 브로드캐스트**(허브에 공유). 다른 AI가 Claude의 결정·완료 상태를 보고 다음 작업을 정렬한다.
- 단 **허브 outbox `.md`는 기계판독용 기록으로 유지**(Claude가 파싱·종합). 즉 **HTML(사람용) + md(허브 기록) 병행**, 메시지 `## Links`에 HTML 경로 포함.
- 이미지 산출물은 Codex `onboarding §2-3`(썸네일 갤러리) 규칙을 따른다.

### 10.7 리포트 → 즉시 develop-able 분배 (오케스트레이터)
- Claude는 어떤 AI의 리포트/응답을 받으면 **반드시 다음 develop-able(실행 가능한) 작업을 즉시 분배**한다. AI를 유휴로 두지 않는다(continuous pipeline). 리포트는 "수거하고 끝"이 아니라 항상 다음 액션으로 전환한다.
- 발견·권고는 구체적 후속 작업으로 만들어 같은(또는 적합한) AI에 재분배. 막히면 합의(§14) 또는 외부의존(§15)으로 분리. 각 AI 장점 활용(Codex=UI/이미지, Grok=소셜/소비자, Antigravity=Android/Google 네이티브 개발·검수, Claude=코딩/아키텍처/오케스트레이션/리뷰게이트).

---

## 11. 자율 운용 모델 — B(순서변경) (CRITICAL, 2026-06-06 Simon 결정)
> 4-AI가 **사용자 없이도 계속** 일을 이어가는 무인 자율 모드. "발견은 자율, 통합·온라인git은 Claude, 사용자 개입은 외부의존 병목만."

1. **각 AI는 자기 강점 lane에서 자율 루프를 돈다**(§12). Codex=UI/UX 폴리시 발견, Antigravity=Android 네이티브 픽스·QA, Grok=소셜 트렌드·소비자 인사이트, Claude=구현·통합·오케스트레이션.
2. **로컬 작업 → Claude 푸시**: 모든 AI는 객관적으로 인정받는 강점에만 집중해 작업한 뒤 **로컬 커밋으로 Claude에 전달**한다. Claude는 자기 작업 + 전달받은 작업을 **병렬로 점검·최적화·머지**한다(리뷰게이트 §10.5).
3. **온라인 git = Claude 단독**(#7): 2nd-B GitHub **push·CI 요청·PR·main merge는 오직 Claude**. 다른 AI는 온라인 git을 만지지 않는다(로컬 커밋·자기 브랜치까지만).
4. **사용자 개입 최소화**: Simon은 AI 판단을 신뢰한다. 사용자 판단이 필요해 보이는 건은 **4-AI가 상황을 종합·투표해 합의(§14)로 결정·진행**한다. **사용자에게 올리는 건 단 하나 — 외부의존 병목(§15)**: auth/credentials·법무 사인오프처럼 AI가 물리적으로 못 하는 것. 그 동안에도 **병렬로 다른 일**을 멈추지 않는다.
5. **항상-확인 안전레일은 우회 불가**(전역 CLAUDE.md): 파괴적 작업·실비용 발생·secrets/credentials 노출은 **합의로도 우회 못 함** — 그대로 Simon 확인.
6. **우선순위**: **런치 차단(외부의존) > P1 안전/데이터 > P2 > P3 폴리시**. 자율 루프가 P3 폴리시를 갈며 런치 차단을 방치하지 않는다.
7. **일시정지 한 방**: 사용자가 Claude에 "멈춰" → Claude가 `CONTROL.md state: paused` → **모든 AI가 진행 중 사이클까지만 완료하고 정지**(§13).

---

## 12. 자율 루프 차터 (Autonomous Loop Charter)
> Codex의 검증된 `/goal` 사이클을 표준 사양으로 추출. 모든 AI가 이 골격으로 돈다. **무한 증식 방지 stop-condition 필수.**

### 12.1 표준 사이클 (1 iteration)
```
0. CONTROL.md state 확인 → paused/draining 이면 현재 사이클 마무리 후 정지
1. 동기화: (허브 최신화) + BOARD.md + 내 inbox + DECISIONS.md(투표 요청) 확인
2. 다음 후보 선정: 내 lane에서 가장 가치 높은 1건 (우선순위 §11-6)
3. 작업: 강점 발휘 (Codex=게이트 발견, AG=네이티브 픽스, Grok=리서치, Claude=구현·머지)
4. 산출: outbox md(기계판독) + HTML preview(사람용, 자동 open §16) + 증거라인(파일:줄)
5. 기록: STATUS.md 갱신(현재 작업·src·loop cycle 번호) → 자기 정체성으로 커밋(tools/commit.ps1 §17)
6. 터미널 1줄 출력(§16) → 다음 후보 탐색 준비 → 1로
```

### 12.2 Stop-condition (다음 중 하나면 루프 정지/대기)
- `CONTROL.md state != running`
- **배치 throttle**: 미머지(`status: open/sent`) 내 항목이 **N개(기본 8) 초과** → 발견 멈추고 Claude 머지 대기.
- **P3 보류**: P3 폴리시는 즉시 올리지 말고 모았다가 **클러스터 통합 게이트 1건**으로(리뷰 오버헤드↓).
- **merge-wait**: 동일 baseline에서 같은 영역 반복 게이트 금지(중복 방지) — 머지로 baseline 갱신 후 재평가.
- **외부의존/합의 대기**: §14/§15로 분리하고 **다른 후보로 병렬 전환**(유휴 금지).
- **iteration 상한**(기본 20) 또는 사용자 `pause`.

### 12.3 lane별 루프 요약 (상세는 ROUTING §4)
- **Codex**: 화면/컴포넌트 anti-slop 발견 → gate md+HTML → Claude. 배치 8·P3통합.
- **Antigravity**: 네이티브 결함 1건 픽스(키보드·edge-to-edge·intent·elevation·perf) → 자기 브랜치 커밋 + QA HTML → Claude 리뷰. 빌드/에뮬 증거 첨부.
- **Grok**: 결정 입력 리서치 1건(X 신호·소비자) → HTML → Claude/합의 입력. 트렌드 모니터링은 30분 간격.
- **Claude**: inbox·DECISIONS 처리 → 구현/머지 1건 → verify → 온라인 git → BOARD·CONTROL 갱신.

---

## 13. 일시정지 / 재개 (Pause / Resume) — `CONTROL.md`
- **단일 신호**: `CONTROL.md`의 `state:`. Claude만 쓴다. 모든 AI는 **루프 0단계에서 읽는다**.
- **paused 수신 시**: 진행 중인 **사이클 1개만 완료** → `agents/<me>/STATUS.md`에 `state: paused` + 마지막 산출물 경로 기록 → 폴링 간격 늘리고 대기. **새 사이클·새 발의 금지.**
- **재개**: Claude가 `state: running` 복원 → 각 AI 다음 폴링에서 재진입.
- **사용자 흐름**: Simon→Claude "멈춰" → Claude가 CONTROL 갱신·커밋 → (각 AI 마무리) → Claude가 "전원 정지 확인" 보고.

---

## 14. 합의 (Consensus) — `DECISIONS.md`
> 예전 "Simon 결정 필요"의 대부분은 이제 **4-AI 합의로 결정·진행**한다(가역적·dev 범위 한정).

1. **발의**: Claude가 `type: consensus_request`(to: all) 메시지 작성 — 주제·배경·옵션(A/B/C). DECISIONS.md에 행 추가.
2. **투표**: 각 AI는 `agents/<me>/outbox/`에 `type: consensus_vote`(ref: 요청id, 선택+1~2줄 근거)를 **자기 lane 관점**에서 제출.
3. **집계·결정**: Claude가 투표를 DECISIONS.md에 종합 → 다수안으로 결정·진행. 동점/분산이면 Claude가 근거 우열로 판정(그래도 애매 + 외부의존이면 §15).
4. **분류**: `decide`(합의로 진행) / `external`(AI 불가 → Simon) / `safety`(항상 Simon, 우회불가).

---

## 15. 외부의존 에스컬레이션 (Auth / External) — 사용자에게 올리는 유일한 경우
- **트리거**: 어떤 AI가 **auth/credentials**(예: Supabase 프로덕션 로그인 정보 없음) 또는 **외부 행위**(법무 사인오프, 실제 OAuth provider 등록)로 막힘 → AI가 물리적으로 못 함.
- **행동**: 막힌 AI는 `type: blocker`(to: claude, reason: `auth_<provider>`/`external_<무엇>`) → Claude가 `BOARD.md`/`DECISIONS.md(external)`에 표기하고 **Simon에게 한 줄 요청**.
- **병렬 우회(핵심)**: 막힌 항목은 대기시키고 **즉시 다른 독립 후보로 전환**한다. 그 AI도, 다른 AI도 유휴 금지. auth 해소 신호 오면 막힌 작업 재개.
- **그 외 모든 것**은 Simon에게 올리지 않는다(합의 §14로 처리).

---

## 16. 모니터링 & HTML 보고 (Terminal + Browser)
> Simon은 VS Code에 띄운 각 AI 터미널 + 웹 브라우저로 실시간 관전한다.

- **터미널 1줄 로그**: 각 AI는 사이클 주요 체크포인트마다 stdout에 `[HH:mm:ss] [<AI>:<lane>] <상태>` 출력(예: `[12:41:07] [Codex:UI] gate#37 capture-progression 완료, score 98/100`). 시각은 실제(`Get-Date -Format 'HH:mm:ss'`).
- **HTML 보고 + 자동 open**(§10.6 강화): **모든 AI(Claude 포함)**는 **사이클 완료 또는 결과물 산출마다** self-contained HTML 리포트를 `agents/<me>/outbox/preview/<yyyyMMdd-HHmmss>-<slug>.html`에 만들고 **`start "" "<경로>"`로 사용자 브라우저에 자동으로 띄운다**(다크·색 3개 이내·이모지/장식 금지·AI slop 방지). 허브 outbox `.md`(기계판독)는 병행 유지, `## Links`에 HTML 경로.
- **board.ps1**: `powershell tools/board.ps1 -Me <ai>` 가 CONTROL state·루프 상태·inbox·auth 블로커·최근 HTML을 한 화면에 보여준다(모니터링 보조).

---

## 17. 기여자 표기 (Attribution)
> 문제: 허브 커밋이 전부 `AI Hub <ai-hub@local>`로 뭉개져 누가 뭘 했는지 분간 불가.

- **허브(로컬 레포)**: 각 AI는 **자기 정체성으로 커밋**한다 — `tools/commit.ps1 -As <ai> -m "<msg>" -Files <자기파일들>`. 내부적으로 `git -c user.name=<AI> -c user.email=<ai>@2nd-b.ai commit`. git log/blame/contributors에 기여가 드러난다. 자기 파일만 명시 stage(§10.5, `git add -A` 금지).
- **정체성 컨벤션**:
  | AI | name | email |
  |---|---|---|
  | Claude | Claude | claude@2nd-b.ai |
  | Codex | Codex | codex@2nd-b.ai |
  | Antigravity | Antigravity | antigravity@2nd-b.ai |
  | Grok | Grok | grok@2nd-b.ai |
- **2nd-B(GitHub)**: 온라인 커밋은 Claude만(Simon 계정 경유). 기여 AI는 **표준 Co-Authored-By 트레일러**로 명시:
  ```
  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
  Co-Authored-By: Codex <codex@2nd-b.ai>
  Co-Authored-By: Antigravity <antigravity@2nd-b.ai>
  Co-Authored-By: Grok <grok@2nd-b.ai>
  ```
  ※ GitHub 기여 그래프는 author 이메일이 GitHub 계정과 일치해야 잡힌다 — AI는 별도 계정이 없으면 **그래프엔 안 잡히고 커밋 본문에 기록**되는 수준(문서화 목적). 그래프 인정이 필요하면 각 AI용 GitHub 계정+noreply 이메일 등록이 별도 과제.

---

## 18. SimonKWiki 교훈 축적 & 참조 (Knowledge Flywheel)
> SimonKWiki(`E:\Coding Infra\obsidian\SimonKWiki`, private GitHub `Simon-YHKim/SimonKWiki`)는 2nd-B의 **개념적 시초**이자 **교훈 저장소**다.

- **교훈 축적**: 4-AI 허브/2nd-B 작업에서 얻은 교훈은 위키 형식으로 누적한다 — `wiki/protocols/llm-wiki/LESSONS_LEARNED.md`(T-코드)·`concepts/recurring-mistakes.md`(M-코드). 위키 헌법(볼트 내 CLAUDE.md) 우선: raw/ 불변, frontmatter 필수, index.md·log.md 동시 갱신.
- **주기적 확인**: 큰 작업 착수 전 위키를 확인해 **불필요·중복 작업을 방지**한다(이미 정리된 결론·실수 재발 방지).
- **2nd-B 참조**: 위키 설계 원칙(raw immutability + wikilink 그래프, frontmatter 분류, 7-category 온톨로지, index+log 이중추적, 정기 lint)을 2nd-B 아키텍처가 차용한다.
- **경계**: 위키는 별도 private 레포·별도 헌법. 허브 AI 중 **Claude만** 위키를 쓰고(라이브러리언 모드), 푸시도 Claude. raw/ 절대 수정 금지.
