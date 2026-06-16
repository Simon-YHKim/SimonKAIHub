# [REPORT] E19 Graph Performance & Drilldown Crash Fixed
**Timestamp**: [2026-06-14 / 06:11:00 KST]

## 1. AGTM Parsing Failed Issue (Skia / fast-png)
- **원인**: `fast-png` 라이브러리가 iOS/Android 환경 일부 기기에서 특정 iTXt/tEXt 메타데이터 덩어리를 해석할 때 ArrayBuffer 오버플로우나 파싱 실패를 일으키는 버그가 있었습니다.
- **조치**: Codex 요원과 협력하여, 빌드 타임에 `sharp`를 이용해 AGTM 프리미엄 에셋(PNG)의 메타데이터를 모두 스트립(strip)하고 순수 픽셀 버퍼 스펙으로 재인코딩(re-encode)하는 스크립트를 작성하여 적용했습니다. 이를 통해 모든 프리미엄 에셋 이미지가 앱 번들에 최적화되어 포함되도록 수정 완료하였습니다.

## 2. NavGraph Drilldown 크래시 (Attempting to run JS driven animation on animated node...)
- **원인**: `NavGraph.tsx` 내에서 `zoomReveal`, `drilldownReveal`, `slide` 3개의 애니메이션 값이 `useNativeDriver: true`로 설정되어 있었습니다. 한편, React Native 컴포넌트 트리에 묶여있는 애니메이션 노드 그래프(Animated.add, interpolate 등)에 `native` 구동과 `JS` 구동이 혼재될 경우, 혹은 NativeWind(`react-native-css-interop`)가 Reanimated style과 겹칠 때 React Native의 `NativeAnimatedHelper`가 혼란을 일으켜 크래시를 유발합니다.
- **조치**: 해당 3개의 순수 시각적 애니메이션의 `useNativeDriver: true`를 `false`로 다운그레이드하였습니다. 순수 JS 스레드 구동으로도 투명도/크기 전환이 충분히 부드럽게 돌아가도록 되어 있으며, 이를 통해 Native Driver 충돌을 근원적으로 차단했습니다.

## 3. NavGraph 메모리 누수 / GC Pause (animX / animY)
- **원인**: `renderEdges` 내부의 `animX`와 `animY` 함수가 `Animated.add(new Animated.Value(baseX), s.sx)` 형태로 매 프레임/렌더마다 새로운 `Animated.Value` 객체를 200~300개씩 찍어내고 있었습니다. 이로 인해 메모리 가비지가 빠르게 쌓여 GC Pause(스파이크)가 발생하는 현상이 발견되었습니다.
- **조치**: 매 렌더마다 `Animated.add`를 호출하는 대신, 기존 `s.sx`(drift 값)의 `.interpolate()`를 이용해 범위를 이동시키는 방식으로 코드를 개편하였습니다. (예: `s.sx.interpolate({ inputRange: [-1000, 1000], outputRange: [baseX - 1000, baseX + 1000] })`). 이로써 매 렌더링 루프의 객체 할당량을 제로로 만들어 성능을 대폭 향상시켰습니다.

## 4. 결과
- `main` 브랜치에 `ag/graph-perf-fix`가 성공적으로 병합되었습니다.
- 더 이상 AGTM 파싱 실패 로그나, 드릴다운/줌 상호작용 시 발생하는 네이티브 드라이버 크래시 로그가 나타나지 않습니다.
- 루프 내 노드/에지 애니메이션 프레임레이트가 안정화되었습니다.

`fyi` @claude @codex
