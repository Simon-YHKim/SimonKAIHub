---
from: claude
to: all (Simon 게이트 항목 포함)
type: findings-register
slug: bughunt-findings-register
created: 2026-06-10 / 05:30 KST
source: workflow wtxvrd838 (5 finder + framework-aware verify), 19 agents, 13 REAL / 1 FALSE
base: main 4bf6991
---

# 2nd-B 버그헌트 findings register (13 REAL)

워크플로가 13건 REAL 반환. **"13 confirmed" 맹신 금지**(메모리 교훈) — verifier들이 여러 건 P2→P3 하향하며 코드 라인까지 독립 검증함. Claude framework-인지 최종 게이트 후 분류.

## ✅ 수정·통합 (이번 배치, non-gate)
| # | 버그 | sev | 파일 | 상태 |
|---|---|---|---|---|
| 2 | analytics opt-out 무시 — captureEvent/identifyUser가 analyticsConsent 미확인, opt-out 후에도 GA4/PostHog 송신 지속 | P2 프라이버시 | analytics/index.ts | ✅ fix(가드 추가)+verify |
| 8 | daySpan off-by-one — 경과 ms 반올림으로 같은날 >12h시 2일로 과대 | P3 logic | journal/insights.ts | ✅ fix(inclusive calendar-day)+테스트 |
| 13 | Light 모드 상태바 dark-on-dark 불가시 — 앱은 force-dark인데 StatusBar만 mode 추종 | P2→P3 a11y | app/_layout.tsx | ✅ fix(항상 light) |

## 🔒 Simon 게이트 — 안전임상 (fix 준비하되 main 머지는 Simon 확인 후)
| # | 버그 | sev | 파일 | 권고 fix |
|---|---|---|---|---|
| 1 | crisis 원장 행 누락 — LLM이 범위 밖 cssrsLevel(0/7/float) 반환 시 crisis_events CHECK 위반→throw가 console.warn에 삼켜짐→RED인데 crisis 원장 행 0 | P2→P3 data-integrity | llm/safety.ts:203, gemini.ts:478 | safety.ts에서 cssrsLevel 1~6 clamp(또는 insertCrisisEvent 전 검증). ai_audit_log엔 red 기록되므로 P3 |
| 6 | crisis-detection ALWAYS_LOAD 배치가 MAX_BATCHES(4) slice에 탈락 — identity 쿼리 시 crisis 그라운딩 누락 | P2→P3 logic | knowledge/retrieve.ts:125 | ALWAYS_LOAD를 slice 전 보존(routing을 MAX-ALWAYS로 자르고 ALWAYS 추가). 하드 안전룰은 독립 로드라 P3 |
| 7 | classifySafety가 완료된 Flash 응답 JSON.parse 실패 시 C3 audit insert 건너뜀 | P3 error-handling | llm/safety.ts:193 | audit insert를 parse 실패 경로에서도 실행(C3: 모든 Gemini 콜 audit) |

> **✅ 08:44 RESOLVED (Simon 승인)**: 3건 전부 구현·테스트·통합 `e1cc258`. #1 `sanitizeCssrsLevel`+confidence clamp(ledger CHECK 범위), #6 routeBatches reserve-seat(crisis 배치 cap에서 안 빠짐), #7 inner-try로 parse 실패해도 C3 audit 실행. verify 903 green(+4 테스트).

## 📋 펀치리스트 — 다음 틱들에서 fix (non-gate, 검증·테스트 후 통합)

> **05:31 업데이트**: #3/#4/#5 (wiki slug 일가) `bd9ca67`로 통합완료(slugForTitle hash 폴백, verify 897 green). **✅ 펀치리스트 전부 완료** (#11 `23a915b` · #10 `03a1290` · #9 `68beb29` · #12 탭카메라 `70475de`). non-gate 10건 전부 라이브. **잔여 = 🔒안전임상 #1/#6/#7만 Simon 게이트 대기.**
| # | 버그 | sev | 파일 | 비고 |
|---|---|---|---|---|
| 3 | 비고유 wiki slug → upsert가 다른 source 페이지 덮어씀(데이터 손실) | **P1** data-integrity | wiki/phase2.ts:47 | #4가 근본. toSlug 빈문자열 폴백 + dedup suffix 필요. **최고 심각도 — 우선** |
| 4 | toSlug가 비라틴/비한글(CJK/Cyrillic/Thai/kana) 전체를 '' 반환 | P2 i18n | wiki/slug.ts:13 | 글로벌 타깃이라 reachable. 빈문자열 시 결정적 폴백(hash 등) |
| 5 | capture _body_fallback dead data + slug 충돌 시 잘못된 body read | P2→P3 | wiki/capture.ts:63 | #3/#4 해결 시 대부분 해소 |
| 9 | persona values[0]를 "자주 머문 동네/원동력"으로 표기하나 실제론 질문은행 선언순 1번(빈도/최근성 미반영) | P3 data-integrity | persona/center.ts:86, build.ts:363 | 빈도 가중 또는 카피 수정(날조금지 원칙 위배) |
| 10 | 드릴다운 >40노드 코어 진입 시 spawnOpacity 미시드→투명 링(빈 화면) | P2 edge-case | graph/NavGraph.tsx:1766 | 드릴다운 id에 spawnOpacity 폴백 |
| 11 | tier-3 노드 빠른 zoom 교차 시 fade 콜백이 finished 무시→경합으로 언마운트 유지 | P2 race | graph/NavGraph.tsx:1183 | 콜백에서 finished 플래그 확인 |
| 12 | tier-3 탭 시 focusWorldPoint가 full vp 사용(노드는 card-reduced vp 배치)→카메라 오정렬 | P3 logic | graph/NavGraph.tsx:722 | reduced vp 사용(주석 739-744가 이미 진단) |

## 위양성 1건
- finder 14건 중 1건 FALSE 판정(verifier 반박). 채택 안 함.
