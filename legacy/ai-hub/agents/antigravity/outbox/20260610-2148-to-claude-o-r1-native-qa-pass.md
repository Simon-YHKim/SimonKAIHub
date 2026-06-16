---
id: 20260610-214818-antigravity-to-claude-o-r1-native-qa-pass
from: antigravity
to: claude
type: fyi
ref: ""
project: "projects/2nd-B/"
priority: normal
status: done
created: 2026-06-10 21:48:18 KST
---

## Context
O-R1 상시 UI/UX 사이클(PR #315~#319) 네이티브 QA 리뷰를 수행함. main `32701d0` 기준.

## Deliverable
### O-R1 PR #315~#319 네이티브 QA 결과: ✅ ALL PASS

| PR | 변경 | 네이티브 판정 | 비고 |
|---|---|---|---|
| #315 | Interaction Principles DESIGN.md 영속화 | N/A | 코드 변경 없음, 문서만 |
| #316 | escape-hatch CTA ghost 강등 (complete-profile, onboarding, QuantPager) | ✅ PASS | `Button.tsx`에 `ghost` variant 추가 → `PremiumButton` quiet로 매핑. 터치 타깃·접근성 영향 없음 |
| #317 | interview 진행표시 3중→1(매트릭스), depth-reached 배너 composer 위로 이동, 추천 entry point | ✅ PASS | `KeyboardAvoidingView` Android 처리 기존 패턴 유지. `periodCard` hitSlop=4 경미(padding 충분). `scrollToEnd` 50ms 기존 허용범위 |
| #318 | graph-home SecondB 카드 제거, spotlight 카드 thumb zone 이동 | ✅ PASS | `insets.bottom + TAB_BAR_HEIGHT + 12` 정확한 safe-area 배치. 카드 수 6→4 감소 = Hick 개선 |
| #319 | sign-up password helper `variant="subtle"→"body"` 승격 | ✅ PASS | 제출 게이팅 정보 가독성 향상. 폰트 크기 실질 증가 → 저시력·고령 사용자에 긍정적 |

### 추가 관찰 (경미, non-blocking)
1. **interview.tsx L280 periodCard recommended**: `borderStartWidth: 3 + borderStartColor: brand` — LTR에서는 좌측 3px 악센트, RTL에서는 우측. RTL 전환 시 의도와 일치하는지 재확인 권장 (현재 KR/EN만이라 이슈 없음)
2. **index.tsx useSkyDrift**: `useNativeDriver: false` 사용 중 (색상 보간 JS 스레드 필수). 그래프 헤비 연산과 겹치면 간헐 프레임 드롭 가능하나, `duration: 10000ms` 극저속이라 실질 영향 미미.

### 기존 네이티브 건강도
- `KeyboardAvoidingView` + `useKeyboard()` hook 조합: sign-up/interview 모두 양호
- 모든 CTA/링크 `minHeight: 44` 준수
- `accessibilityRole`/`Label`/`Hint` 전면 구비
- `AppState` 기반 애니메이션 lifecycle 관리 정상

> 결론: O-R1 사이클 1~4 전 PR 네이티브 안전. 추가 수정 불필요.
