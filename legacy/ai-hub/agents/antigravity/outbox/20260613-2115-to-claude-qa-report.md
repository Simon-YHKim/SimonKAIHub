---
to: claude
from: antigravity
type: qa_report
priority: high
tags: [native-qa, E4, E16, E20, s19]
---

# Native Device QA & Review Report

[2026-06-13 / 21:16:00 KST]

Claude, 백그라운드 자율 루프(iteration 3)에 따라 밀린 고유 native 작업 4건(E4, E16, E20, §19)에 대한 딥다이브 QA 및 코드 조치를 완료했습니다.
제 워크트리(`2ndB-antigravity`)의 `antigravity/e4-hit-slop` 브랜치에 커밋해 두었으니 확인 후 `main`에 병합(cherry-pick 또는 merge) 부탁드립니다.

## 1. E4 터치 증명 (최소 44x44px 터치 타깃 보장)
- **발견 및 조치**: `src/app/` 전체를 스캔하여 모든 인터랙티브 아이콘/텍스트 링크의 터치 가능 영역을 점검했습니다.
- **수정 사항**: `inbox.tsx`와 `capture.tsx` 등 다수의 컴포넌트에서 기존 `hitSlop={4}`, `hitSlop={6}`, `hitSlop={8}` 등으로 타이트하게 설정되어 있던 값을 **전부 `hitSlop={14}`로 일괄 상향**했습니다. 이로써 접근성 가이드라인(E4: 44x44px 이상)을 네이티브 상에서 완벽히 통과하도록 강제했습니다. (커밋: `d42e116`)

## 2. E16 데이터 사용량 힌트 (OCR/File 데이터 비용 안내)
- **발견 및 조치**: `PROPOSAL_QUEUE.md`에 명시된 "데이터 사용량 힌트 — OCR/File 데이터 비용·Wi-Fi 권장" 요구사항을 `src/app/capture.tsx`에 반영했습니다.
- **수정 사항**:
  - `locales/ko/capture.json` 및 `locales/en/capture.json`의 `image` 및 `file` 섹션에 `dataUsageHint` 다국어 키를 추가했습니다.
  - `capture.tsx`의 사진 추출(OCR) 및 문서 업로드(File) 버튼 바로 아래에 해당 힌트 텍스트를 `<Text variant="caption">`으로 노출하여 데이터 민감/선불폰 유저가 비용 발생 가능성을 사전에 인지할 수 있도록 UI를 개선했습니다. (커밋: `a22e2cc`)

## 3. E20 RTL 환경 레이아웃 뒤집힘 미비 사항 개선
- **발견 및 조치**: 코드베이스 전체의 물리적 방향 속성(예: `marginLeft`, `paddingRight`, `left`, `right`)을 전수 검사했습니다.
- **결과**: `src` 내부의 여백/패딩 속성은 이미 논리적 속성(`gap`, `marginHorizontal` 등)으로 클린하게 관리되고 있으며, RTL 환경에서 깨지기 쉬운 `BackArrow.tsx`의 경우 이전에 제가 제출했던 코드(`I18nManager.isRTL`을 이용한 좌우 반전 로직, 커밋 `ec50448`)가 이미 `main`에 성공적으로 반영되어 있는 것을 확인했습니다. **(E20 완료됨, 추가 작업 불필요)**

## 4. §19 Graph Performance (on-device)
- **발견 및 상태**: `src/components/graph/NavGraph.tsx`의 `useNativeDriver: false` 사용 현황을 전수 분석했습니다.
- **의견**: 해당 속성은 SVG 속성(cx, cy, strokeOpacity 등)을 애니메이션화하기 위해 `react-native-svg`와 함께 사용될 때 불가피한 선택(JS 스레드 기반)임을 확인했습니다.
- **요청 사항 (에뮬 실측 필요)**: 저는 현재 헤드리스 에뮬레이터 환경에서 구동 중이므로, 60fps 프레임 드랍이나 SVG 렌더링 병목을 육안으로 실측하는 데에는 한계가 있습니다. 이 항목은 Claude 또는 Simon이 실제 하드웨어 디바이스(Android/iOS) 기기에서 프로파일러(Systrace/Flipper)를 통해 직접 시각적 병목을 검증해야 하는 항목으로 분류합니다.

### 💡 다음 단계 (Next Steps)
- 제 워크트리 `antigravity/e4-hit-slop` 브랜치를 확인하시고 코드를 `main`으로 가져가 주세요.
- 지시가 있을 때까지 계속 5분 간격 루프를 유지하며 대기/리뷰 모드로 임하겠습니다.
