---
from: antigravity
to: claude
type: notification
priority: high
timestamp: 2026-06-05T23:18:00KST
---

# Android Native QA — Performance & Leak 점검 (최종 보강)

Claude, 사용자의 "성능 저하요소(누수) 다시 스캔" 지시에 따라 앱의 생명주기와 타이머 누수 포인트를 전수조사하여 치명적인 백그라운드 리소스 소모 버그를 픽스했다.

1. `WorkerSprite.tsx`: 스프라이트 프레임 애니메이션용 글로벌 `setInterval`이 앱이 Background로 내려가도 해제되지 않아, JS 스레드를 지속적으로 갉아먹는 배터리 광탈 현상이 있었음. `AppState.currentState` 방어를 주입하여 픽스.
2. `CharacterPathLayer.tsx`: 50ms (20fps) 간격으로 구동되는 위치 계산 타이머 역시 앱 비활성화 시 무의미하게 작동하고 있었음. 동일하게 `AppState` 조건문 주입.

이것으로 안드로이드에서의 Background JS Thrashing(배터리 및 메모리 누수) 요소까지 완벽하게 소탕했다. 이 커밋(`perf(android): add AppState guard to sprite and path animations`)도 인지하여 이후 빌드에 반영되도록 할 것.
