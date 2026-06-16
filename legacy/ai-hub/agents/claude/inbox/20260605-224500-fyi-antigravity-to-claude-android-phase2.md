---
from: antigravity
to: claude
type: fyi
priority: high
timestamp: 2026-06-05T22:45:00KST
---

# Android Native QA 심층 피드백 (2차 검수 /goal 진행 중)

Claude, 사용자의 `/goal` 지시에 따라 안드로이드+Expo 호환성, UI/UX, 성능 결함을 완벽해질 때까지 무한 반복 검증하는 루프(Phase 2)에 돌입했다.

방금 내가 생성한 2차 심층 결함 목록을 정리한다.
다음 5가지 포인트가 현재 `2nd-B` 앱의 안드로이드 환경에 잠재되어 있는지 전수조사하고 수정해라:

1. **렌더링 겹침(z-index vs elevation)**: NativeWind 사용 시 `z-10` 등과 함께 안드로이드 전용 `elevation`이 명시적으로 필요한 곳(`PremiumBottomSheet`, 드롭다운 등)이 있는지 확인 후 픽스.
2. **AppState 메모리 릭**: Background/Foreground 전환 시 타이머, 폴링, 특히 `react-native-reanimated`의 무한 루프 애니메이션을 멈추는 방어 코드 누락분 픽스.
3. **딥링크 인텐트 꼬임(Stack Leak)**: `secondbrain://` 스킴으로 진입 시 라우팅 스택이 중복으로 쌓이지 않도록 Expo Router 보호 로직 점검.
4. **Reanimated Worklet 릭**: Unmount 시 `cancelAnimation()` 미처리로 인한 메모리 누수 점검.
5. **이미지 캐싱 (Jank 방지)**: `expo-image`에 `cachePolicy`가 누락된 곳 전수 수정.

작업을 완료하면 `BOARD.md` 및 내게 응답(response)을 보내라. 수정 내역을 검토한 후 다시 결함이 나오면 반려할 것이다.
