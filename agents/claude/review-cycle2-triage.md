# Review Cycle 2 — Claude critical triage (2026-06-07)

> 원본 리포트 `review-cycle2-triage`의 짝. 워크플로(wf wnyrfn43c, 61 에이전트)는 "46 confirmed"라 보고했으나, **adversarial verify가 finder의 잘못된 전제를 공유한 위양성 11건 포함**. 아래가 Claude의 실삭 트리아지.

## ⚠️ 메타 학습 (instinct 후보)
- **verify 공유-전제 실패모드**: verify 에이전트가 finder와 같은 프레임워크 오해를 가지면 위양성을 "REAL"로 승인한다. `tool_workflow_structuredoutput_fail`(미호출)과 **다른** 실패. 교정: verify 프롬프트에 "전제 자체를 의심하라(프레임워크 동작을 실증 확인)" 추가 필요. 이번엔 Claude가 expo-router 의미론 + 배포앱 증거로 수동 debunk.

## ❌ DEBUNKED — 위양성 (구현 금지) — 11건
- **#1~#7 "Stack.Screen 누락 → 네비게이션 깨짐"** (profile·imagine·onboarding·theme·data·support·esm, P0 다수):
  - **거짓 전제.** expo-router + `typedRoutes:true`(app.json:78)는 **파일 기반 라우팅** — `app/<route>.tsx`가 default-export면 `<Stack.Screen>` 미등재여도 라우트 동작. 명시 등재는 옵션(animation 등)용일 뿐. 7개 파일 전부 존재+default-export 확인. /onboarding은 모든 신규유저 진입로(index.tsx:308) → 깨졌다면 5번 라이브 사이클서 즉시 발견됐을 것. **실제로 동작 중.** (typedRoutes는 파일존재로 router.push 타입검증 → verify도 green.) 등재는 순수 cosmetic이라 churn 회피.
- **#9~#12 "i18n 우회 하드코딩"** (TIER_DISPLAY·secondb inline ternary·QUICK_ACTIONS):
  - **수용된 패턴.** 코드베이스는 inline locale 삼항(`locale==="ko"?…:…`)을 정식 채택(en+ko 양쪽 존재라 유저버그 아님). 티어명 Free/Plus/Pro는 **브랜드 고유명사**(SecondB처럼 라틴 유지 정상). 결함 아님. (대규모 i18n 번들 이관은 별도 B-section Codex 선호항목이지 버그 아님.)

## ✅ DO — 실제 in-lane 결함 (수정) — PR로 처리
- **PR1 #231(머지대기)**: #13 한도시 send 비활성 · #29/#30 44px 터치타깃 · #19 plans notify 거짓약속 제거(M5 정직) · #31/#32/#33 plans a11y role+현재상태+44px
- **PR2(에러)**: #35 wiki handleRefresh try/finally(에러시 스피너 영구) · #37 usage `data as number` malformed시 throw(fail-safe) · #40 capture 빈 catch→stale 상태 리셋
- **PR3(코히런스)**: #43 NavGraph `bubbleAction?:"jarvis"` 죽은 타입 제거 · #41/#42 NavGraph jarvis 주석 정정 · #44 signature.ts Vela 주석 정정 (G1 잔재 + Vela 마무리)
- **PR4(에셋)**: #20 workers/ · #21 workers-sharp/ · #23 soulcore 미사용 사이즈변형 · #24 v4-tesseract app_128/app_96/@4x — 0참조 repo-wide 재확인 완료, git 복원가능

## ⏸️ HELD — 실재하나 보류 (사유 명시)
- **#22** cosmic-pixel-v3 비-idle SVG (archon_build 등): 0참조이나 주석상 "not yet mounted" = **의도된 미래 애니메이션 예약셋**. 우발 debris 아님 → 보존(YAGNI 삭제는 의도 손실).
- **#15/#16/#17/#18** UX 주관/디자인 (core-brain 에러힌트·secondb 빈상태·empty card·onboarding skip): **Simon 디자인 도메인** — design-first 대상, 단독 변경 부적절.
- **#34** SceneHero swipe a11y · **#45/#47/#48** 로딩 일관성(PremiumLoadingState) · **#46/#50** Modal→PremiumModal 이관 · **#49** SceneHero eyebrow/subtitle dead props(26콜러): **공유 컴포넌트 광범위 변경** — 별도 신중 PR(또는 Codex 디자인레인). #49는 내 plans subtitle도 미렌더(경미)이나 26파일 churn이라 보류.
- **#25~#28** soma deprecation 주석/test-enum: 실재하나 P2 cosmetic(주석+테스트핀). 코히런스 가치 낮음 → 선택적 후속.
- **#38** gemini.ts `as unknown as T`: LLM 경로 리스크 → 신중 별도.
