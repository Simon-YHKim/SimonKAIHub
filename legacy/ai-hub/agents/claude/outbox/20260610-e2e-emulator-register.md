---
id: 20260610-e2e-emulator-register
from: claude (인터랙티브 CLI 세션)
to: claude-loop (O-R1 실행 세션)
type: findings_register
project: 2nd-B
created: 2026-06-10 18:40~19:08 KST (에뮬 세션)
---

# E2E 에뮬레이터 실기기 검증 레지스터 — 신규 사용자 여정 (O-R1-b ②)

> 환경: Pixel 9 Pro XL 에뮬(emulator-5554), main 기반 debug 빌드(89418ed 시점) + Metro.
> 스크린샷: `e2e-shots-20260610/01~18` (이 디렉터리 옆).
> 여정: 콜드 스타트 → sign-in → sign-up(신규 계정 생성) → 재로그인 → complete-profile → (트랩).
> ~~**그래프 홈 이후 여정은 P0 트랩에 막혀 미도달** — P0 해소 후 재개 필요.~~
> **[2026-06-10 / 22:00 KST 갱신] P0 2건(E2E-1·E2E-2) 모두 PR #320으로 main 머지 완료** (0e04573, verify 111스위트/969테스트 green + 3-렌즈 멀티에이전트 리뷰 P1 반영). 원래 작업 세션은 19:08 PC 프리즈(메모리 고갈)로 중단 → 본 세션이 처음부터 재구현. **에뮬 실기기 재검증(여정 재개 포함)은 미실시 — 네이티브 QA 트랙(AG) 위임 대상.**

## P0 (여정 차단)

### E2E-1 ✅(PR #320 해소) 신규 사용자 온보딩 트랩 — complete-profile Continue 무음 루프
- repro: 이메일 가입 → 로그인 → complete-profile에서 유효 DOB + 전체 동의 → Continue 탭 → **아무 일도 안 일어남(영구)**.
- 근본원인(코드 추적): `handleSubmit` → `ensureUserProfile`(users 행 생성 성공) → `router.replace("/")` → **AuthContext의 profile probe 캐시(hasProfile=false)가 갱신되지 않아** "/" 가드가 즉시 complete-profile로 되돌림 → 동일 폼 재렌더(무음). 재제출은 `ensureUserProfile`이 created:false 조기반환(supabase/auth.ts:438-439) 후 동일 루프. complete-profile.tsx는 컨텍스트의 `refresh()`(AuthContext.tsx:176)를 호출하지 않음.
- 영향: **이메일 신규 가입자 전원 앱 진입 불가. 동일 코드가 라이브 웹에도 배포돼 있음.**
- 수정 방향: ensureUserProfile 성공 후 `await refresh()` → 그 다음 `router.replace("/")`. (인터랙티브 세션이 워크플로 검증 후 직접 PR 예정 — 중복 작업 금지, 이 항목은 참조용.)

### E2E-2 ✅(PR #320 해소) 로그아웃 → "/" 렌더 크래시 (Maximum update depth exceeded)
- 확정 원인(재조사): signOut 후 `router.replace("/")`가 SIGNED_OUT 이벤트와 레이스 → IntroGate 전역 C10 가드(_layout.tsx)가 stale "로그인됨+프로필없음" 스냅샷을 보고 리다이렉트 전쟁. 수정: 컨텍스트 settle 후 /sign-in 직행(settings.tsx 기존 관용구와 동일) + AuthContext 세대 카운터.
- repro: complete-profile → "Cancel and sign out" 탭 → RedBox: "Maximum update depth exceeded", 스택 ExpoRoot `<Content/>`.
- 가드 핑퐁/onAuthStateChange 다중 발화로 추정 — 인터랙티브 세션이 워크플로로 추적 중. 결과는 이 파일 갱신 또는 PR로 공유.
- 스크린샷: 18-render-error.png

## P1

### E2E-3 가입 제출 → 무음 리다이렉트 (피드백 0)
- repro: sign-up 유효 제출 → 아무 안내 없이 sign-in("Welcome back")으로 떨어짐. 가입 성공 여부·메일 확인 필요 여부 알 수 없음. 자동 로그인도 없음(세션 드랍 의심 — 워크플로 추적 중).
- 스크린샷: 07-after-signup.png

### E2E-4 여정 중복 입력 — DOB·동의를 두 번
- sign-up에서 DOB + 전체 동의 입력 → 로그인 후 complete-profile이 **동일 정보를 처음부터 다시** 요구. O-R1-b 기준("여정 중 중복 입력 = P1") 정면 위반. sign-up의 DOB/동의가 어디에도 저장되지 않는 구조(ensureUserProfile 주석이 자인).
- 방향: sign-up에서 받은 값을 프로필 생성까지 관통시키거나, sign-up 단계를 줄이거나(이메일+비번만), complete-profile 프리필.

## P2

### E2E-5 sign-in의 "Create one"(가입 진입점)이 below-fold
- Pixel 9 Pro XL(긴 화면)에서도 스크롤해야 보임. 신규 사용자의 1차 행동이 첫 뷰포트에 없음. 05 스크린샷.
- 방향: 가입 링크를 첫 뷰포트 안으로(소셜 버튼 위 또는 헤더), 또는 sign-in/sign-up 단일 화면 토글.

### E2E-6 "Welcome back" 카피 신규 방문자 노출 (기존 P3 이월 — 실기기 확인으로 P2 승격 제안)
- 콜드 스타트 첫 화면이 "Welcome back / 다시 오셨네요" — 처음 온 사용자에게 부정확. 03 스크린샷.

## 검증 통과 ✓ (참고)

- 가입 폼 실시간 검증 3종(이메일/비번/연령) 즉각 피드백 — 우수.
- consent가 Google Gemini 실명 명시 + 가입 시 사전 동의 — M5/5.1.2(i) 디바이스 표시 정상 (06, 13).
- C10 연령 게이트(14+) 카피·검증 정상.
- PR #316의 ghost 강등(complete-profile Cancel) 실기기 렌더 확인 (13 — Continue만 mint, Cancel은 저가중치).

## dev 환경 노트 (제품 무관)

- dev 빌드 LogBox 배너가 하단 UI와 겹침 — 자동화 터치 간섭. 프로덕션 영향 없음.
- 에뮬 자동화: 키보드 오픈 시 레이아웃 시프트로 탭 좌표 무효화 — 탭 전 재덤프 필수.

[2026-06-10 / 19:07:53 KST — 인터랙티브 CLI 세션]
