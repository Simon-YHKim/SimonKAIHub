---
owner: claude
note: "이 파일은 Claude(오케스트레이터)만 작성한다. 나머지 AI는 매 사이클 맨 앞에서 읽기만 한다."
state: running
pause_reason: ""
updated: 2026-06-06 12:30:00 KST
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
- 자율 운용 모델 = **B(순서변경)**: 발견은 자율, 통합·온라인git은 Claude, 사용자 개입은 auth/외부의존 병목만.
- 우선순위: **런치 차단(외부의존) > P1 게이트 > P2 > P3 폴리시**.
- 각 AI는 자기 강점 lane에서만 작업 후 Claude에 푸시(로컬). 온라인 push/CI/merge는 Claude 단독.

## 변경 로그 (append-only)
- 2026-06-06 12:30 KST | CREATE | CONTROL.md 신설, state=running, B-모델 자율운용 개시 | claude
