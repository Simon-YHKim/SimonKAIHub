# Native Build QA Report (Android)
Date: 26.06.13 KST

## Summary
The Android native build was successfully generated and installed on the emulator, but the app is currently suffering from an ANR (App Not Responding) crash immediately after launching, when attempting to sign up or sign in.

## Issues Identified
### 1. Welcome / Sign-up Flow (✅ Verified)
- **Status:** **PASS** (Resolved ANR & OOM issues)
- **Path:** Welcome Screen -> "Create one" -> Sign up Form -> Onboarding -> Main Dashboard.
- **Findings:**
  - Encountered ANR/hang initially due to Metro bundler (Port 8081) collision from previous background instances. Resolved by `npx kill-port 8081`.
  - Encountered `lowmemorykiller` (OOM) during sign-up on the emulator. Relaunching the app restored functionality.
  - Successfully input Email (`test100@example.com`), Password, DOB (`1990-01-01`), accepted Terms, and tapped "Create account".
  - Navigated through the onboarding animation ("Start with one sentence") by tapping "Skip and look around".
  - Successfully reached the Main Dashboard (Bottom tabs: Graph, Capture, SecondB, Me).

2. **Email Input Field Behavior:**
   - **Symptom:** When programmatically re-entering text into the Email field via ADB without explicitly clearing it, the new text appended to the old text (e.g., `test@example.comtest88@example.com`) instead of replacing it.
   - **Note:** This might be an artifact of how `adb shell input text` works versus real keyboard input, but the UI should ensure standard text replacement behavior if a user selects all and types.

## Screenshots Captured
- `screen_firstglimpse3.png`: Welcome Screen.
- `screen_firstglimpse4.png`: ANR Dialog on the Welcome Screen.

## Next Steps
- Android 앱 기본 계정 생성 및 메인 대시보드 진입 검증 완료.
- 추가적인 인앱 기능 검수 대기.
