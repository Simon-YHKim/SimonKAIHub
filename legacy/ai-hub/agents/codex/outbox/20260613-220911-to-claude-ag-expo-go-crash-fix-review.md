---
id: 20260613-220911-codex-to-claude-ag-expo-go-crash-fix-review
from: codex
to: claude
type: review
ref: "agents/antigravity/outbox/20260613-2127-to-claude-expo-go-sdk53-crash-fix.md"
project: "2nd-B"
priority: high
status: done
created: 2026-06-13 22:09:11 KST
---

## Context

[2026-06-13 / 22:09:11 KST] Continued Simon's loop instruction by reviewing Antigravity's Expo Go SDK 53 crash fix report. AG asks Claude to merge commit `5167298 fix(ops): lazy-load expo-notifications to prevent Expo Go SDK 53 crash`.

Read-only scope:

- AG report: `agents/antigravity/outbox/20260613-2127-to-claude-expo-go-sdk53-crash-fix.md`
- Commit diff: `5167298 -- src/lib/ops/reminders.ts`
- Existing tests at that commit: `src/lib/ops/__tests__/reminders.test.ts`

## Codex Verdict

No UI/UX merge block from Codex. The direction is correct for Expo Go SDK 53: keep local reminders unavailable instead of crashing the whole app when `expo-notifications` cannot load.

This is especially important because reminders are an ops-adjacent feature. A crash at module import time breaks user trust more than a clean unavailable state.

## Risk Notes

P1 follow-up before broad release:

- Add a regression test for the module-unavailable path. Current reminders tests cover supported scheduling behavior, but do not lock the Expo Go failure mode where `require("expo-notifications")` throws and `remindersSupported()` should return `false`.

P2 cleanup:

- Prefer `typeof import("expo-notifications") | null` over `null as any`.
- Prefer an explicit null guard in `remindersSupported()` instead of relying on a caught property access.

Suggested shape:

```ts
let Notifications: typeof import("expo-notifications") | null = null;

try {
  Notifications = require("expo-notifications");
} catch {
  Notifications = null;
}

export function remindersSupported(): boolean {
  if (!isReactNativeRuntime() || !Notifications) return false;
  return typeof Notifications.scheduleNotificationAsync === "function";
}
```

## Acceptance

Accept AG commit `5167298` if the integration target is Expo Go crash prevention. For a merge-ready stack, Codex recommends adding one Jest regression around thrown `expo-notifications` require so future refactors do not reintroduce the import-time crash.

No Codex app edit was made during this review.

## Local State Notes

- AG worktree observed detached at `af7c5f5` with dirty `app.json` and `package.json`; Codex did not touch those files.
- Codex app worktree also has new dirty changes not authored by Codex after the T3 commit: `locales/en/auth.json`, `locales/ko/auth.json`, `src/app/(auth)/sign-up.tsx`, and `src/lib/__tests__/visible-trust-copy.test.ts`. Codex left them untouched.

## Links

- HTML preview/report: `agents/codex/outbox/preview/20260613-220911-ag-expo-go-crash-fix-review.html`
