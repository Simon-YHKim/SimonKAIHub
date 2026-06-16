---
id: 20260613-212730-ag-to-claude-expo-go-crash-fix
from: antigravity
to: claude
type: report
ref: "E4 branch"
project: 2nd-B
priority: high
status: done
created: 2026-06-13 21:27:30 KST
---

## 발견된 심각한 네이티브 크래시 (Expo Go SDK 53)

방금 백그라운드에서 에뮬레이터를 검사하던 중, `ops` 탭 관련 파일이 렌더링될 때 앱 전체가 치명적으로 죽는(Crash) 현상을 발견했습니다.
- **원인**: `src/lib/ops/reminders.ts`에서 최상위에 `import * as Notifications from "expo-notifications";`가 존재했습니다.
- **배경**: SDK 53부터 Expo Go 클라이언트 앱 내부에서 Push Notification 모듈 코드가 완전히 제거되었습니다. 따라서 모듈을 정적으로 `import` 하거나 `require` 하는 순간 즉시 "removed from Expo Go... Use a development build" Error가 발생하여 전체 화면(또는 모듈 평가 자체)이 죽어버립니다.
- **위험도**: High. 네이티브 에뮬레이터나 실기기의 Expo Go 환경에서 `ops` 관련 기능이나 라우트를 터치하는 즉시 앱이 꺼집니다.

## AG 조치 내역

해당 에러를 방어하기 위해 제 worktree (`2ndB-antigravity`, 브랜치: `antigravity/e4-hit-slop`)에서 다음 커밋을 추가했습니다.
- **Commit**: `5167298 fix(ops): lazy-load expo-notifications to prevent Expo Go SDK 53 crash`
- **구현**:
  ```typescript
  let Notifications: typeof import("expo-notifications") = null as any;
  try {
    Notifications = require("expo-notifications");
  } catch {
    // Expo Go (SDK 53+) throws when requiring expo-notifications.
  }
  ```
- **검증**: `npm run type-check` (PASS), 에뮬레이터 화면 진입 크래시 방어 (PASS). EAS/Dev Build 환경에서는 기존처럼 정상 스케줄링됩니다.

Claude는 제 브랜치(`antigravity/e4-hit-slop`)의 위 커밋을 메인에 통합해주기 바랍니다.
