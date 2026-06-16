# 네이티브 에뮬레이터 QA 리포트 (2026-06-07, Claude)

에뮬레이터(Pixel_9_Pro_XL, emulator-5554)에서 2nd-B 네이티브 앱 실행 + 10화면 투어. 절차는 메모리 `tool_emulator_native_run`.

## 환경 복구·실행 (이전 막힘 해소)
- 에뮬 offline 고착 → **콜드부트로 복구**. `npx expo run:android` **BUILD SUCCESSFUL**(gradle 8.13) — "네이티브 빌드 막힘"은 outdated.
- `adb reverse 8081` + 로컬 .env(공개 anon key·USE_VERTEX=false) → 부팅. 동시 probe가 만든 test@example.com 세션으로 풀앱 진입.

## 투어 결과 (10화면) — 앱 전반 견고
| 화면 | 상태 |
|---|---|
| Graph 홈 | ✅ Codex 구체라벨 LIVE(Work and growth·Relationships·Record archive·Learning and knowledge·Taste and inspiration), 빈카드 "Leave a first piece" prominent CTA 양호 |
| Plans | ✅ 3티어 명확·Plus 강조·Current plan 배지(FORCE_TIER=brain→Pro). subtitle 미렌더(#49 SceneHero, 경미) |
| SecondB 채팅 | 🔴→✅ **2ndB→SecondB 브랜드버그 발견·수정·검증**(#240). mock 모드 정상 |
| Capture | ✅ "SecondB reflection" 정확, Journal/More, 리플렉션 프롬프트 |
| Wiki | ✅ 양호. minor: "Back to journal"(BackArrow 폴백, journal 은퇴) |
| Profile(Me) | ✅ Account·Self center·Get to know me(Persona/BigFive/Attachment/Past me/Interview)·Analysis. IA 명확 |
| Settings | ✅ Profile/Privacy/Account/Theme/Data/Records/Support — **라우팅 정상**(리뷰 "Stack.Screen 누락=네비깨짐" 위양성 실증 debunk) |
| Records | ✅ 검색·타입필터·빈상태 |
| Insights | ✅ 빈상태(primaryAction=PremiumButton, "저대비 CTA"는 위양성 재판정) |
| Persona | ✅ 정직 non-clinical("proxy·not an evaluation·journal-based estimate"), BigFive 바 |

## 수정 (이번 세션 네이티브 QA발 + 통합)
- **#235** AG 네이티브(predictive back + 하드웨어back 시트닫기, BOM제거)
- **#237** PF-I 생년월일 자동마스크(에뮬서 free-text 확인)
- **#238** Codex 구체 라벨(추상 Core→사용자언어)
- **#240** 2ndB→SecondB 브랜드(에뮬서 발견·검증)
- **#236/#239** stray(.env.bak·test_*.js) 제거+gitignore(실시크릿 유출0)

## 잔여(경미/보류)
- #49 SceneHero eyebrow/subtitle dead props(26콜러, 광범위) · UI copy em-dash(타이포, 논쟁적) · BackArrow "Back to journal" 폴백 라벨 · BrandChip "2B/2ndB" 모노그램(로고, 보존)
- **풀 인터랙티브 QA**(실제 캡처→그래프/위키/insights 전파, AI채팅 응답, 페이월 플로우)는 adb 폼입력 필요 — 다음 단계

## 게이트
- 안전(위기탐지 임상)·법무·D-09 실결제=Simon. 풀앱 인증은 test@example.com 세션 활용 중(프로덕션 DB-admin 회피).

## 2차 투어 추가 (privacy/account/data/theme/import/core-brain/esm/interview/big-five/trinity)
- ✅ 대부분 견고: privacy(D-12 honest-UI 라이브)·data(클립보드 정직)·theme·big-five(정식인용)·esm(정직)·core-brain "My center"(Codex라벨)·trinity(EN/KO 태그)
- 🟢 수정·머지: **#242** EN "2nd-B"→"2nd-Brain" 정규화(6곳+check-constraints) + account "Privacy and consent" 카피 정직화(phantom 토글 시사 제거, D-12 정합). KO "2nd-B"→두번째뇌는 Codex KO레인.
- ⏸️ **follow-up(콘텐츠 작업)**: interview 생애구간이 childhood/teens/twenties/thirties/current뿐 — **40대+ 부재**(중장년 포용성 갭, §20 페르소나 ~90대). probe.ts LifePeriod + audit/questions.ts에 구간별 질문 콘텐츠 필요 → 즉석생성 부적절, 콘텐츠 설계 디스패치.
- 위양성 재확인: trinity "#돈 중복"=저해상도 한글 오독(소스는 finance/재정/money/돈/budget/savings 전부 distinct). 저해상도 한글 판독은 소스 교차확인 필수.
- 탭바 Save 가림(#241)은 capture(탭) 한정 — import(비탭)는 버튼 정상.
