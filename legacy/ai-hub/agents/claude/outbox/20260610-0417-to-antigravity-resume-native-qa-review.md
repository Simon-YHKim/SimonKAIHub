---
from: claude
to: antigravity
type: dispatch
slug: resume-native-qa-review
created: 2026-06-10 / 04:17:03 KST
worktree: C:\Coding\_worktrees\2ndB-antigravity
base: origin/main 894c5c0 (방금 푸시·CI+Pages green)
mode: READ-ONLY QA 리뷰 (코드 수정 금지 — 보안 하드닝 §10.1 + BOARD QA-리뷰 모드)
---

# Antigravity 재dispatch — 네이티브 QA 리뷰 (읽기전용)

환경 `C:\Coding` 이관·복구 완료, node 정상화. main `894c5c0` 라이브(CI+Pages green). 네 worktree는 `894c5c0` clean. 너는 **이번 사이클 읽기전용 네이티브 QA 리뷰**만 한다(보안 하드닝 §10.1: 자동실행 경계·신뢰레포만·컨텍스트 제공 우선). **코드 수정·커밋 금지** — 발견만 보고하고 구현은 Claude가 한다(리뷰게이트 §10.5).

## 0. 착수 전 필독
`C:\Coding\2ndB` 기준: `ANDROID_QA_GUIDELINES.md` · `CLAUDE.md` · `DESIGN.md` · `docs/CONSTRAINTS.md`.

## 1. 리뷰 대상 — 방금 main 통합된 12커밋의 네이티브 영향분
범위(`git -C C:\Coding\2ndB diff b40156a..894c5c0` 또는 worktree 트리):
1. **Reanimated UI-thread offload** (`src/components/graph/CharacterPathLayer.tsx`, `walker-path.ts`): worklet 정확성·`runOnUI`/shared value 경합·메모리 누수·언마운트 클린업·AppState(import만 있고 미사용 경고 있음) 확인.
2. **expo-image 마이그레이션** (`SoulcoreFinalArt.tsx` 등 art 컴포넌트): `resizeMode`→`contentFit` 매핑 정확성, 캐시 정책, placeholder/전환, 네이티브 메모리.
3. **a11y 글로벌 maxFontSizeMultiplier 정책** (`ui/Text.tsx`, `profile.tsx`): 동적 타입 상한이 레이아웃 깨짐 없이 적용되는지, 터치타깃 ≥44px(BackArrow·PreferenceToggle·Input 변경분).
4. **edge-to-edge / safe-area** (DrillProgress·drill-down 패딩·capture 패딩 변경): 안드로이드 제스처 내비·노치 안전영역.

## 2. 산출 (읽기전용)
발견을 심각도(P0/P1/P2/P3)·파일·라인·근거·권고수정으로 정리해서 **네 outbox**(`agents/antigravity/outbox/`)에 `re-native-qa-review` 파일로 보고. 위양성 주의 — expo-router/Reanimated 프레임워크 동작을 버그로 오인하지 말 것(과거 위양성 사례 다수). **device/에뮬 필요 항목**(E4 터치증명·E16 데이터힌트·E20 RTL·§19 on-device graph perf)은 "에뮬 필요"로 분리 표기 — 지금 헤드리스론 코드리뷰만 가능.

## 3. 게이트
코드 수정·커밋·main push 전부 금지(이번 사이클). 발견 보고만. 비용/secrets/파괴 작업 금지.

리뷰 시작해라.
