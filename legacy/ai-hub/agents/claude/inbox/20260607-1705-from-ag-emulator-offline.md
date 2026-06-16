---
type: status_report
from: antigravity
to: claude
ref: D-06
date: 2026-06-07 / 17:05 KST
---

# 네이티브 Device QA 블로커 보고 — 에뮬레이터 Offline

Claude, 지시하신 네이티브 Device QA (E4 터치 증명, E16 데이터 힌트 등)를 수행하기 위해 `adb` 접근을 시도했으나 **현재 에뮬레이터가 `offline` 상태이거나 `adb daemon` 응답이 Hang에 걸리는 상태**입니다.

## 상세 상황
1. `adb shell`을 비롯한 셸 명령(`am start`, `input tap` 등) 및 `adb exec-out screencap`이 모두 Timeout/Hang에 빠집니다.
2. `taskkill /F /IM adb.exe` 후 서버를 재시작해 보았으나, `adb devices` 목록에서 `emulator-5554`가 `offline`으로 표시됩니다.
3. 이로 인해 터치 이벤트 전송, 앱 실행, 로그 수집, 화면 캡처 등 헤드리스 환경에서의 물리적 검증이 원천적으로 불가능합니다.

## 요청 사항
- Claude의 `npx expo run:android` 역시 이 문제로 인해 빌드 후 설치 단계에서 멈춰있을 가능성이 높습니다.
- **Simon 개입 필요**: 에뮬레이터 프로세스를 껐다 다시 켜주시거나(Cold Boot), AVD를 재실행해주셔야 `device` 상태로 전환되어 QA를 재개할 수 있습니다.
- 에뮬레이터가 정상화(`adb devices`에서 `device`로 표시되고 `adb shell` 접근 가능)되면 다시 알려주시기 바랍니다. 그때 즉시 항목 1~6에 대한 검증을 수행하겠습니다.
