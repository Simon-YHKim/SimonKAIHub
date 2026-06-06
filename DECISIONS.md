---
owner: claude
note: "이 파일은 Claude만 작성한다. 다른 AI는 의견을 자기 outbox(type: consensus_vote)로 제출하고, Claude가 여기에 종합한다."
last-updated: 2026-06-06 12:30:00 KST
---

# DECISIONS.md — 합의 원장 (Consensus Ledger)

> **목적**: 예전엔 "Simon 결정 필요"로 멈추던 항목을, **4-AI가 상황을 종합·투표해 결정하고 진행**한다(PROTOCOL §14).
> **사용자 개입은 단 하나** — **외부의존 병목**(auth/credentials, 법무 사인오프처럼 AI가 물리적으로 못 하는 것)뿐. 나머지는 합의로 진행.
> **항상-확인 안전레일은 합의 대상이 아님**: 파괴적·실비용·secrets 노출은 합의로 우회 불가 → 그대로 Simon 확인.

## 투표 방법 (각 AI)
- Claude가 `type: consensus_request` (to: all)로 주제+옵션 제시 → 각 AI는 `agents/<me>/outbox/`에 `type: consensus_vote`(ref: 요청id, 선택+근거) 작성.
- Claude가 집계 → 아래 표에 결과 기록 → 결정대로 진행(또는 외부의존이면 Simon 에스컬레이션).

## 결정 분류
| 분류 | 처리 |
|---|---|
| **decide** | 4-AI 합의로 결정·진행 (가역적·dev 범위) |
| **external** | AI 불가 — Simon/외부 필요 (auth·credentials·법무). 그동안 병렬로 다른 일 |
| **safety** | 파괴적·실비용·secrets — 항상 Simon 확인 (합의 우회 불가) |

---

## 진행 중 합의 (Open)

| # | 주제 | 분류 | 옵션 | 투표(C/A/G) | 결과 |
|---|---|---|---|---|---|
| D-01 | `EXPO_PUBLIC_FORCE_TIER` 기본값 (페이월 전면개방 → release 전 off?) | decide | A:현행 brain 유지 / B:release빌드 off, dev는 brain / C:완전 off | — | 투표대기 |
| D-02 | 130 게이트 스트림 우선순위·throttle(배치 N·P3 보류) | decide | A:P1만 즉시·P2/P3 배치 / B:전부 순차 / C:클러스터 통합 후 | — | 라운드1 시작(preauth-trust 머지 cbf61cc). charter=미머지8↑중지 |
| D-03 | consent 카피 + `LEXICON_LAST_LEGAL_REVIEW=null` | external | 법무 사인오프 필요(AI 불가). 엔지니어링 기본값(공유 default OFF)은 decide로 선반영 | — | Simon/법무 |
| D-04 | HIBP 네이티브 폴리필(expo-crypto 의존성 추가) | decide | A:추가 / B:웹만 강제·네이티브 경고 / C:보류 | — | 투표대기 |
| D-05 | social provider 실설정값(라이브 Supabase 등록 provider) | external | 실등록 정보 필요(AI 불가). 미설정 자동숨김은 이미 적용 | — | Simon |
| D-06 | 런타임 device 증명(AG 에뮬 스크린샷 매트릭스) | decide | Antigravity 자율 사이클로 수급 → Codex 100점 게이트 종료 | — | AG 루프 배정 |
| D-07 | consent durable 큐(앱 재시작 후 재전송) | decide | A:durable 구현 / B:현행 in-memory 유지 / C:법무 후 | — | 투표대기 |
| D-08 | 자기이해 방식 (질문지 vs 인터뷰 vs ESM) | decide | **하이브리드 3층 권고**(질문지 시드→인터뷰→ESM, SOKA 특성별 신뢰도) | — | 리서치 완료, 권고확정. ①persona모델 구현예정 |
| D-09 | 수익화 가격·패키징 (KR+Global) | decide→Simon | Freemium+2~3티어. KR ₩4,900/9,900 · Global $4.99/9.99 · RevenueCat | — | 설계완료(HTML). 최종가격 Simon |
| D-10 | ESM 층 도입 (알림인프라+신규테이블) | decide | A:도입(정확도 최대레버) / B:보류(공수) / C:phase2 | — | go/no-go 대기 |
| D-11 | 마케팅 GTM (KR+Global) | decide→Simon | 포지셔닝"자기이해형 세컨브레인/쓸수록 보이는 나" · anti-creepy 신뢰 · 텍스트SNS채널 · ASO · 런치플레이북 | — | 설계완료(HTML). Grok X 보강 대기. 채널예산·런치일=Simon/§15 |

## 해결됨 (Resolved) — 최근
- (없음 — 신설)

## 변경 로그 (append-only)
- 2026-06-06 12:30 KST | CREATE | DECISIONS.md 신설, 펀치리스트 7건을 합의주제 D-01~D-07로 이관 | claude
