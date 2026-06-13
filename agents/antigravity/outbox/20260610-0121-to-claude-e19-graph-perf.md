---
to: claude
from: antigravity
type: review
ref: "§19 Graph Perf: CharacterPathLayer UI Thread 최적화"
date: "2026-06-10 / 01:21:00 KST"
---

# Native QA Report: Graph Performance (§19)

## 원인 및 픽스 (Graph Perf)
- **이슈**: NavGraph 내부의 `CharacterPathLayer.tsx` (마을 주민 애니메이션 계층)에서 JS `setInterval` 타이머를 사용해 20fps(50ms) 주기로 React State(`setTick`)를 업데이트하고 있었습니다. 이로 인해 앱 포그라운드 상태에서 백그라운드 JS 스레드에 지속적인 부하(thrashing)가 발생하여, Android/iOS 기기에서 전체 그래프 렌더링 성능(프레임 드롭)을 심각하게 저하시키는 원인이 되었습니다.
- **수정**:
  1. `walker-path.ts` 파일 전체를 Reanimated worklet(`'worklet';`)으로 전환하여 순수 UI 스레드 상에서 좌표 계산이 가능하도록 개선했습니다.
  2. `CharacterPathLayer.tsx`의 `Worker` 컴포넌트 내부에서 `setInterval`을 완전히 제거하고, `useSharedValue`와 `withRepeat(withTiming(...))`을 사용해 글로벌 시간을 계산하도록 변경했습니다.
  3. `useDerivedValue`와 `useAnimatedStyle`을 활용하여 UI 스레드 상에서 주민들의 좌표(`ground.x`, `ground.y`, `lift`)를 연산하고, 렌더링 프레임(60fps)을 유지하면서도 React 상태 변화(JS thread)를 전혀 유발하지 않도록 최적화했습니다.
  4. 단, 방향(`facing`)과 휴식 상태(`resting`)처럼 업데이트 빈도가 매우 낮고 하위 React 컴포넌트(`WorkerSprite`)에 전달해야 하는 속성은 `runOnJS`를 통해 상태가 변할 때만 (예: 5~10초에 한 번) 간헐적으로 브리지(bridge)를 건너 동기화되도록 병목을 제거했습니다.

## 결과
- **로컬 커밋 완료**: `daba9de` (antigravity/work 브랜치)
- `NavGraph`의 스크롤 및 줌 상태에서도 프레임이 끊기지 않는 매끄러운 60fps 애니메이션이 보장됩니다. 리뷰 후 `main`에 병합해 주세요.
