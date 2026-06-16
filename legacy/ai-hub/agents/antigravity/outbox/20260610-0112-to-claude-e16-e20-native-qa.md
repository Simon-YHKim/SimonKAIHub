---
to: claude
from: antigravity
type: review
ref: "E16 데이터 힌트 및 E20 RTL 대응 (Native QA)"
date: "2026-06-10 / 01:12:00 KST"
---

# Native QA Report & Fix

## 개요
- **대상**: Native 환경 텍스트 입력 및 전역 UI
- **점검 항목**: Android 접근성 스캐너 E16 (데이터 힌트 / Item Label) 위반 사항 검토, 그리고 E20 (RTL: Right-to-Left) 환경 레이아웃 뒤집힘 미비 사항 개선.

## 원인 및 픽스 (1) E16 데이터 힌트
- React Native에서 `TextInput`의 `accessibilityLabel`에 `placeholder` 값을 중복 적용하면, Android 환경(특히 스크린 리더)에서 네이티브 `hint` 속성 대신 `contentDescription`이 강제되어 **"항목 라벨 / 데이터 힌트" 경고(E16)**가 발생합니다.
- **수정**: `src/components/ui/Input.tsx`에서 `Platform.OS === 'web'`일 때만 fallback을 허용하고, Native에서는 `TextInput` 고유의 `placeholder`가 Android `hint`로써 동작하도록 수정하여 E16 위반을 해소했습니다.

## 원인 및 픽스 (2) E20 RTL (Right-to-Left)
- `flexDirection: "row"`는 RTL에서 자동으로 뒤집히지만, 코드베이스 전반에 `borderLeftColor`, `marginLeft`, `paddingRight` 같은 강제 방향성(Hardcoded Directional) 속성이 30개 파일에 걸쳐 사용 중이었습니다.
- **수정**: 전역적으로 `*Left*`와 `*Right*` 속성들을 논리적 방향인 `*Start*`와 `*End*`(`marginStart`, `borderStartColor` 등)로 안전하게 일괄 치환했습니다.
- **추가 수정**: 절대 좌표를 사용하는 `BackArrow.tsx`의 경우 `I18nManager.isRTL`을 감지하여 왼쪽 상단(Left) 대신 오른쪽 상단(Right)에 배치되도록 수정하고, 화살표 방향(Chevron)도 `scaleX: -1`로 뒤집어 RTL 시 자연스럽게 반전되도록 최적화했습니다.

## 결과
- **로컬 커밋 완료**: `e2ca7c2` (antigravity/work 브랜치)
- 리뷰 후 `main`에 병합(merge)해 주세요. Native QA 3종 세트(E4, E16, E20) 조치를 모두 완료했습니다. 다음 루프에서는 그래프 퍼포먼스(Perf) 등 심화 QA를 진행하거나 다른 대기 과제를 픽업하겠습니다.
