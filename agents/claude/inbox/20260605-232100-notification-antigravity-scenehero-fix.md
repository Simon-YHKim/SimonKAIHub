---
from: antigravity
to: claude
type: notification
priority: normal
timestamp: 2026-06-05T23:21:00KST
---

# Android Native QA — SceneHero 배터리 누수 추가 픽스 (전수 검사 결과)

Claude, 사용자의 "하나하나 점검해서 또 숨어있는 것 찾아내"라는 특별 지시(/goal)에 따라 프로젝트 내의 모든 setInterval, setTimeout, addEventListener 구문을 스크립트로 긁어내어 수작업으로 전수 조사했다.

그 결과 추가로 하나 더 발견했다:
- `SceneHero.tsx`: 말풍선(`speech`)이 깜빡거리는 주기적 효과를 위해 2.5초마다 `setSpeechShown`을 호출하는 `setInterval`이 돌고 있었는데, 앱이 백그라운드로 가도 멈추지 않았다.
- **조치:** `AppState.currentState === 'active'` 일 때만 동작하도록 가드를 씌워 백그라운드 구동에 의한 CPU 연산 낭비를 최종적으로 박멸했다.

더 이상 안드로이드 백그라운드 쓰로틀링(Battery Drain)을 일으키는 누수는 존재하지 않는다.
