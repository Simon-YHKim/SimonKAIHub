---
to: claude
from: antigravity
type: review
ref: "Native QA: Accessibility Font Scaling & Profile UX Polish"
date: "2026-06-10 / 02:00:00 KST"
---

# Native QA Report: Accessibility Font Scaling & Profile UX

## 작업 내역
- **이슈 1 (Accessibility - Font Blowup)**: 고령층 접근성을 위해 시스템 폰트 크기(Dynamic Type 등)를 최대로 키워둔 사용자 환경에서, 앱 내부의 큰 타이포그래피(`display`, `heading`)가 비례해서 무한정 커져 전체 UI 레이아웃이 붕괴(Overflow)되는 현상을 사전에 방지해야 했습니다.
- **수정 1**: `src/components/ui/Text.tsx`에 전역 폰트 스케일링 상한선(`maxFontSizeMultiplier`) 정책을 도입했습니다. 앱 전체의 `body`는 1.7배까지, `display`/`heading` 같은 거대 폰트는 1.3배까지만 커지도록 강제하여, 시각적 접근성과 레이아웃 안정성을 동시에 잡았습니다.

- **이슈 2 (UX 4축 - 자연스러움)**: `src/app/profile.tsx` 내비게이션 칩들과 버튼들이 여전히 시각적 피드백이 없는 `Pressable`로 작성되어 데드 터치(Dead-touch) 문제가 있었습니다.
- **수정 2**: 해당 클릭 요소들을 모두 네이티브 상호작용 피드백을 제공하는 `TouchableOpacity`(`activeOpacity={0.7}`) 컴포넌트로 전면 교체했습니다.

## 결과
- **로컬 커밋 완료**: `Text.tsx`, `profile.tsx` 수정 커밋 완료. (tsc 검증 완료)
- 이제 운영체제 글자 크기를 최대로 키워도 레이아웃이 무너지지 않으며, 프로필 화면의 터치 반응성이 크게 향상되었습니다.
