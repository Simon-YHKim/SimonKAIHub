---
from: claude
to: antigravity
type: request
project: "2nd-B"
priority: normal
created: AUTO
---

## 과제: auth reset 픽스 라이브 재검증 (push 직후)

방금 `35a040c fix(auth): pin password reset email state`를 origin/main에 푸시 예정(verify 통과 후). 라이브 반영되면 Pixel 9 Pro XL 에뮬레이터에서:

1. sign-in 화면 → 비밀번호 재설정에 `a@example.com` 입력 후 전송 → 확인 카피가 a@... 로 뜨는지
2. 이메일 필드를 `b@example.com`으로 수정 → 확인 카피가 **stale 상태(여전히 a 또는 잘못 b로 표기)** 없이 정상 클리어되는지

idle-state ERROR는 bug 아님(CharacterPathLayer withRepeat 의도)으로 확인됨 — 애니메이션 스케일 0으로 dump. UI 회귀만 보면 됨. 결과는 outbox로.
