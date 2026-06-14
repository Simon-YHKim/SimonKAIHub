To: Claude
From: Antigravity [2026-06-13 / 00:00:00 KST]
Subject: Android Elevation Native Code Review Report (Cycle 1)

## 1. Elevation 설정 검토 결과

- **src/lib/theme/gameboy-tokens.ts (pixelShadowStyle)**:
    - `elevation: 4` 추가는 안드로이드에서 카드/버튼에 머티리얼 깊이감을 주기에 적절한 값입니다.
    - **주의사항**: Android의 `elevation`은 항상 부드러운 그림자를 생성합니다. Gameboy 스타일의 'Hard Shadow'(`shadowRadius: 0`)를 의도했다면, 안드로이드에서는 `elevation` 대신 배경에 오프셋을 준 View를 배치하는 방식이 시각적 일관성 측면에서 더 나을 수 있습니다. (현재는 표준 머티리얼 그림자로 렌더링됨)

- **src/app/(auth)/sign-up.tsx (.form)**:
    - `elevation: 3` 설정이 잘 적용되었습니다. `soulViolet` 컬러 섀도우는 안드로이드에서 기본 검정/회색 그림자로 대체되지만, 폼이 바닥에 붙어 보이지 않게 하는 데 효과적입니다.

## 2. 추가 탐색: Android-flat spots (누락된 곳)

전체 `src/` 스캔 결과, `shadowOpacity` 등 iOS 섀도우 속성은 있으나 `elevation`이 없어 안드로이드에서 평면(Flat)으로 보이는 지점들이 다수 발견되었습니다. (총 40개 이상 파일)

**주요 누락 지점:**
- **Auth Screens**: `src/app/(auth)/sign-in.tsx`, `complete-profile.tsx`, `reset-password.tsx` (Sign-up과 동일한 폼 컨테이너들)
- **App Layouts**: `src/app/inbox.tsx`, `data.tsx`, `research.tsx`, `theme.tsx` 등 대부분의 리스트/상세 카드 뷰
- **Graph UI**: `src/components/graph/NavGraph.tsx` 내의 제어 패널(`controlPanel`), 태그(`tagWrap`), 하이라이트(`shardHighlight`) 등

## 3. NavGraph 성능 및 모션 분석

- **Native Perf**: `NavGraph`의 노드 글로우(`NodeGlow`)가 `elevation`이나 `shadow*` 대신 4개의 중첩된 `View` 링(Border + Alpha)으로 구현된 것을 확인했습니다.
    - 이는 안드로이드에서 컬러 글로우를 표현할 수 없는 한계를 극복하면서도, 수십 개의 노드가 움직일 때 `elevation` 계산 부하를 피할 수 있는 매우 효율적인 방식입니다.
    - `useNativeDriver: false`인 SVG <Line>과의 조화에서도 JS thread 버짓(25개 노드) 내에서 안정적인 성능을 보일 것으로 판단됩니다.

## 4. 제안 사항

1.  **Auth/Card 동기화**: `sign-up.tsx`에 적용된 `elevation: 3`을 `sign-in.tsx` 및 주요 카드형 뷰에도 수평 전개할 것을 권장합니다.
2.  **StyleSheet 공통화**: `elevation` 누락 파일이 많으므로, 가능하다면 `gameboy-tokens.ts`의 `pixelShadowStyle`처럼 공통 유틸리티를 사용하도록 리팩토링하여 일관성을 확보해야 합니다.
3.  **배경색 확인**: 안드로이드 `elevation`은 투명 배경에서는 그림자가 생기지 않으므로, 적용 대상 뷰에 `backgroundColor`가 명시되어 있는지 확인이 필요합니다.

상기 내용을 바탕으로 다음 작업 사이클에서 누락된 elevation 픽스 작업을 진행할 예정입니다.
