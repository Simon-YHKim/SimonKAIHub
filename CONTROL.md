---
owner: claude
note: "이 파일은 Claude(오케스트레이터)만 작성한다. 나머지 AI는 매 사이클 맨 앞에서 읽기만 한다."
state: running
pause_reason: ""
updated: 2026-06-07 07:59:10 KST
---

# CONTROL.md — 런-스테이트 세마포어 (always-checked)

> **목적**: 4-AI가 무인 자율로 도는 동안 "전체 멈춤/재개"를 단일 신호로 통제한다.
> **규칙**: 모든 AI는 **자기 자율 루프의 맨 앞에서 이 파일의 `state:`를 읽는다.** Claude만 쓴다(single-writer).

## 상태 값
| state | 의미 | 각 AI 행동 |
|---|---|---|
| `running` | 정상 가동 | 자율 루프 계속 (charter 한도 내) |
| `paused` | 일시정지 | **진행 중인 사이클 1개까지만 완료** → `agents/<me>/STATUS.md`에 `state: paused` + pause-ack 기록 → 대기. 새 사이클 시작 금지 |
| `draining` | 정리 종료 | 진행 중 작업만 마무리, 신규 발의 금지, 완료 후 idle |

## 일시정지 프로토콜 (PROTOCOL §13)
1. 사용자가 Claude에게 "일시정지/멈춰/pause" → Claude가 이 파일 `state: paused` + `pause_reason` + `updated` 갱신 후 커밋·푸시.
2. 각 AI는 다음 루프 진입 시 `paused` 감지 → **현재 사이클만 마무리** → STATUS에 `state: paused` 기록 → 대기(폴링 간격 늘림).
3. 재개: Claude가 `state: running` 복원 → 각 AI 재진입.

## 현재 지시(broadcast) — Claude가 갱신
- 자율 운용 모델 = **B(순서변경)**: 발견은 자율, 통합·온라인git은 Claude, 사용자 개입은 **비용발생/파괴적/secrets 병목만**.
- 우선순위: **런치 차단(외부의존) > P1 게이트 > P2 > P3 폴리시**.
- 각 AI는 자기 강점 lane에서만 작업 후 Claude에 푸시(로컬). 온라인 push/CI/merge는 Claude 단독.

### 🆕 2026-06-07 07:59 운용 규칙 강화 (Simon 지시)
1. **루프 주기 = 5분.** 각 AI는 한 사이클 종료 후 약 5분 대기(`Start-Sleep 300` 또는 동등) 뒤 CONTROL을 재확인하고 다음 사이클. 무한 풀가동 금지·유휴 금지의 중간.
2. **타임스탬프 양식 통일 = `[YYYY-MM-DD / HH:MM:SS KST]`.** 모든 자율 아웃풋(터미널 1줄·STATUS·outbox·HTML·커밋 보고)에 현재 KST 시각을 이 양식으로 명시. 실제 실행: PowerShell `Get-Date -Format 'yyyy-MM-dd / HH:mm:ss'` 뒤 ` KST` 부착(시간 추정 금지).
3. **적극성 의무.** 수동 대기 금지. 자기 강점 lane에서 **먼저 나서서** 할 일을 발굴·제안·수행한다. 할당이 비면 BOARD/DECISIONS/코드를 스스로 훑어 다음 가치작업을 만들어 착수.
4. **별도공간 → Claude 검토 → 결정.** 모든 산출물은 자기 worktree/outbox 등 별도 공간에서 작업하고, Claude에 보고. **채택·실제파일 반영·온라인 git은 Claude가 검토 후 결정**(단독).
5. **사용자 권한 필요 시 4-AI 토론(§14).** "사용자 결정/승인 필요"로 보이는 건은 곧장 Simon에게 올리지 말고 **4-AI가 `type: consensus_request`로 타당성을 토론·합의해 적용**한다. **예외(항상 Simon 확인) = ①비용발생(결제·유료 API) ②파괴적 작업 ③secrets/credentials.** 이 셋만 사용자 에스컬레이션, 나머지는 합의로 자율 진행.

## 변경 로그 (append-only)
- 2026-06-06 12:30 KST | CREATE | CONTROL.md 신설, state=running, B-모델 자율운용 개시 | claude
- 2026-06-07 07:40 KST | PAUSE | Simon "하던일까지만 하고 일시정지". 최종 머지 30dc939까지 완료 후 정지. 각 AI 현재 사이클 마무리 후 대기 | claude
- 2026-06-07 07:59 KST | RESUME | Simon "허브 구동" 지시 → state=running 복원. 4-AI 재가동(activate 프롬프트 재배포) | claude
