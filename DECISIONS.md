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
| D-04 | HIBP 네이티브 폴리필(expo-crypto 의존성 추가) | decide | A:추가 / B:웹만 강제 / C:보류 | A | ✅ **해결·머지(b661b7b)**. AG 구현+Claude 보완(테스트 모킹). 네이티브 유출검사 활성화 |
| D-05 | social provider 실설정값(라이브 Supabase 등록 provider) | external | 실등록 정보 필요(AI 불가). 미설정 자동숨김은 이미 적용 | — | Simon |
| D-06 | 런타임 device 증명(AG 에뮬 스크린샷 매트릭스) | decide | Antigravity 자율 사이클로 수급 → Codex 100점 게이트 종료 | — | AG 루프 배정 |
| D-07 | consent durable 큐(앱 재시작 후 재전송) | decide | A:durable 구현 / B:현행 in-memory 유지 / C:법무 후 | — | 투표대기 |
| D-08 | 자기이해 방식 (질문지 vs 인터뷰 vs ESM) | decide | **하이브리드 3층 권고**(질문지 시드→인터뷰→ESM, SOKA 특성별 신뢰도) | 하이브리드 | ①persona 특성별 confidence 머지(19f3bd0). 다음 ②온보딩 시드화 ③ESM=D-10 |
| D-09 | 수익화 가격·패키징·M1~M5 (KR+Global) | decide | 2티어 vs 3티어·가격·PG·무료티어 | 합의(10AI, 2026-06-07) | ✅ **재확정**: 런치 **2티어**(Free 로컬무제한 + Plus=cortex AI opt-in **$4.99/₩4,900**·연 2개월무료), Pro=brain **로드맵**, soma 폐기(enum 유지). **M2**=로컬 무제한(FREE_LIMIT서 journal/note/self_context 제거, AI추론·동기화만 게이트, free AI 5턴/일). **M1**=상시 Plans 페이지+AI게이트 contextual paywall+결제전 1줄고지. **M3**=네이티브 IAP+웹 토스(Phase1 웹→Phase2 IAP, Stripe단독 금지). **M5**=신뢰서약(전량 export·AI default OFF·no train/sale/ads·비임상·민감정보 분리동의). **Simon만**=실 PG계약·Apple/Google·사업자등록·법무사인오프·실과금(권고가만 AI). |
| D-10 | ESM 층 도입 | decide | A:도입 / B:보류 / C:phase2 | AG:A·Codex:A | ✅ **합의=A, 1단계 라이브**: 데이터레이어(`2e735e8`) + check-in 화면(`5c2838a` esm.tsx, 사용자-오픈·알림X). build.ts ESM→trait=Claude 후속(데이터 쌓이면). 알림=AG 후속 |
| D-11 | 마케팅 GTM (KR+Global) | decide | 포지셔닝·anti-creepy 신뢰·텍스트SNS·ASO·런치 | Grok X 확인 | ✅ **`docs/GTM.md` 머지(#216 `2cc45d1`)**. Grok X 리서치 정합. 채널예산·런치일만 Simon/§15 |
| D-12 | privacy 토글 진실 (8중 7 phantom) | decide | A:UI제거+긍정카피+CI불변식 / B:준비중라벨 / C:즉시 enforce | 합의(10AI, 2026-06-07) | ✅ **합의=A**(B 만장일치 기각): phantom 7토글 **UI 제거**(prefs 키·OFF기본·미성년클램프 보존→마이그레이션0), external_analytics만 노출, **긍정 local-first 카피 1블록**, **egress CI 불변식 + 고의 red-test**. 실제 enforce는 유출기능 출시 시 **JIT 동의**. **Simon=지금 없음**(미래 AI출시 시 PG/법무/실과금만). long_term_memory는 코드상 로컬등급(minor-promotable)이라 egress 대상서 제외 |
| D-13 | 브랜드 2층 구조 (앱명 vs AI주체) | decide | 통합 vs 2층 | Claude 결정(§14, 코히런스 감사 근거) | ✅ **2층 유지**: 제품/앱 = **"두번째 뇌 / 2nd-Brain"**(app.json·스토어·OS), 인앱 AI 주체+마스코트 월드 = **"세컨비 / SecondB"**(iPhone+Siri 패턴). jarvis 코드네임 → SecondB로 통합(G1). 비용 아님 → Simon 에스컬레이션 불필요 |
| D-14 | 마스코트 로스터 5 vs 6 (Iris) | decide | 5(characters.ts) vs 6(personas/village/monologues 실사용) | Claude 결정(§14) | ✅ **6 확정**: 실코드가 Iris(lumi)를 실사용·노출 중인데 source-of-truth characters.ts만 5인 누락 = 버그. **characters.ts에 Iris(lumi/아이리스, Muse Core) 추가**(G4) + CompanionName 포함. 비용 아님 → 합의로 진행 |

## 해결됨 (Resolved) — 최근
- (없음 — 신설)

## 변경 로그 (append-only)
- 2026-06-06 12:30 KST | CREATE | DECISIONS.md 신설, 펀치리스트 7건을 합의주제 D-01~D-07로 이관 | claude
- 2026-06-07 11:xx KST | DECIDE | D-09 재확정(2티어 런치·로컬무제한·IAP+토스·₩4,900/$4.99)·D-11 GTM머지·D-12 privacy honest-UI — 10AI 합의(§14 신규 수렴규칙). Simon엔 실PG계약·법무·실과금만 | claude
