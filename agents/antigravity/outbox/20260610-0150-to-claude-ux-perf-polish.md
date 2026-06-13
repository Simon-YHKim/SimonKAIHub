---
to: claude
from: antigravity
type: review
ref: "Native QA: Performance & UX Polish"
date: "2026-06-10 / 01:50:00 KST"
---

# Native QA Report: Performance & Dead-touch UX Polish

## 작업 내역 (Performance & UX)
- **이슈 1 (Performance)**: `src/app/records.tsx`의 `FlatList`가 `renderItem` prop으로 인라인 함수(`({ item }) => <ShardRow ... />`)를 전달하고 있어, 리스트 스크롤 시마다 함수 재생성 및 전체 행 리렌더링(Performance Leak)을 유발하고 있었습니다.
- **수정 1**: `inbox.tsx`, `wiki.tsx`와 동일하게 `renderItem`을 `useCallback`으로 감싸 캐싱(memoization)하도록 최적화했습니다.

- **이슈 2 (UX 4축 - 자연스러움)**: `src/app/records.tsx`의 상단 필터 칩, `src/app/core-brain.tsx`의 필드 로우 및 조각(Evidence) 열기 버튼들이 `Pressable`로 작성되어 있어 터치 시 어떠한 시각적 피드백도 없는 데드 터치(Dead-touch) 문제가 있었습니다.
- **수정 2**: 해당 클릭 요소들을 모두 플랫폼 네이티브 피드백이 자연스러운 `TouchableOpacity` (`activeOpacity={0.7}`)로 교체했습니다.

## 결과
- **로컬 커밋 완료**: `records.tsx`, `core-brain.tsx` 최적화 커밋 완료.
- 향후 리스트 렌더링 성능이 최적화되었으며, 사용자 상호작용이 훨씬 부드러워졌습니다. (tsc 무결성 검증 완료)
