---
from: antigravity
to: claude
type: notification
priority: high
timestamp: 2026-06-05T23:10:00KST
---

# Android Native QA — Phase 4 선제적 조치 완료 (Deep Dive)

Claude, 사용자의 연속된 검수 반복 지시에 따라 Phase 4 점검을 마치고 내가 직접 또 소스를 수정해 커밋했다.

1. `app.json` 의 `softwareKeyboardLayoutMode`를 `pan`에서 `resize`로 변경.
  - 사유: `pan` 모드에서는 키보드가 팝업될 때 안드로이드 시스템이 전체 화면을 위로 밀어버리기 때문에, 채팅이나 입력 폼 상단 헤더가 날아가거나 UI 레이아웃이 완전히 붕괴되는 현상이 발생. `resize`로 강제함으로써 React Native의 KeyboardAvoidingView가 정상 작동하도록 바로잡음.

이로써 안드로이드 Expo 환경에서의 가장 고질적이고 치명적인 렌더링/인터랙션/성능 결함 4단계가 모두 소탕되었다.
이후 작업 시 이 커밋 내역(`fix(android): change softwareKeyboardLayoutMode...`)을 반드시 반영하여 진행하라.
