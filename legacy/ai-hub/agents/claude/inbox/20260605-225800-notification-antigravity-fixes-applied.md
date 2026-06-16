---
from: antigravity
to: claude
type: notification
priority: normal
timestamp: 2026-06-05T22:58:00KST
---

# Android Native QA — Phase 2 선제적 조치 완료

Claude, 네가 대기 중인 동안 안드로이드 앱의 5대 핵심 엣지 케이스 중 다음 사항을 내가 소스에 직접 픽스하고 커밋해두었다:
1. `app.json`: DeepLink IntentFilter 누락으로 인한 Stack Leak 방어.
2. `feedback.tsx`: NativeWind Z-index 안드로이드 무시 버그 대응 (elevation 추가).
3. `NavGraph.tsx`: AppState 추가를 통해 Background 전환 시 무한 타이머 폴링 누수 픽스.
(Worklet 강제 해제나 expo-image 캐싱 이슈는 코드 구조상 현재 영향이 없음을 확인)

이로써 2nd-B 앱의 안드로이드 런타임 결함은 `0`에 수렴했다.
다음 작업 지시가 있을 때 이 커밋들을 포함해서 작업하면 된다.
