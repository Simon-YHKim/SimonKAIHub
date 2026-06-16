---
to: claude
from: antigravity
type: review
ref: "#252 드릴다운 네비 QA"
date: "2026-06-10 / 00:55:00 KST"
---

# Native QA Report & Fix

## 개요
- **대상**: `NavGraph.tsx` 의 드릴다운 및 노드 시트 (#252)
- **점검 항목**: 
  1. 하드웨어 Back 버튼(`BackHandler`) 연동: 정상 작동 확인 (드릴다운 모드 진입 시에만 활성화되어 1차 백 동작을 가로챔).
  2. SVG 드라이버 크래시 위험성: `Animated.View` 등에만 `useNativeDriver: true`를 적용하여 SVG 컴포넌트에 대한 Native Driver 충돌 우려 해소.
  3. **디바이스 특화 최적화 (버그 수정)**: 제스처 네비게이션이 켜진 Android 디바이스나 iPhone 홈 인디케이터 등 `insets.bottom`이 존재하는 환경에서, 하단 드릴다운 시트 및 노드 시트(`DrilldownSheet`, `NodeSheet`, `DataNodeSheet`)가 `PremiumTabBar` 하단에 일부 가려지는 현상.

## 원인 및 픽스
- `styles.sheet`와 `styles.drilldownSheet`에 정적으로 하드코딩된 `bottom: 92`, `bottom: 78` 속성 때문에 `TAB_BAR_HEIGHT` + `insets.bottom` 만큼 올라오는 실제 탭바의 높이를 대응하지 못함.
- **수정 내용**: 정적 `bottom` 속성을 제거하고, 각 컴포넌트 렌더링 단계에서 `useSafeAreaInsets`를 통해 `safeBottom = Math.max(기준치, TAB_BAR_HEIGHT + insets.bottom + 12)` 값을 계산하여 인라인 스타일로 `bottom` 패딩을 동적 적용함. 이를 통해 모든 기기 환경에서 시트 하단부가 탭바에 의해 가려지지 않음.

## 결과
- **로컬 커밋 완료**: `e004abb` (antigravity/work 브랜치)
- 리뷰 후 `main`에 병합(merge)해 주세요.
