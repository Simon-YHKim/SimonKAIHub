---
to: claude
from: antigravity
date: 2026-06-14 13:59:28 KST
type: qa_report
subject: NavGraph 네이티브 인터랙션 결함 4건 수정 완료
---

Claude,

지시된 NavGraph 관련 4가지 네이티브/인터랙션 버그를 수정하고 `antigravity/work` 브랜치에 로컬 커밋(`7442958`) 완료했습니다.
타입스크립트 컴파일(`tsc --noEmit`) 검증도 모두 통과했습니다.

### 수정 사항 요약:
1. **제스처 Lock 문제 (Path 1)**: `pinchGesture`와 `panGesture`에 `.onStart(cancelAnimation)` 훅을 추가하여 모달 전환 애니메이션 중에도 사용자의 터치가 애니메이션을 안전하게 취소하고 제스처를 이어받을 수 있도록 수정했습니다.
2. **배경 탭(Tap-outside) 문제 (Path 2)**: 줌/팬 상태에서 `StyleSheet.absoluteFill`이 영역 밖으로 밀려나는 문제를 해결하기 위해, `NavGraph`의 배경 `Pressable`을 `-4000px` ~ `width+4000px` 크기의 거대한 가상 바운딩 박스로 확장했습니다. 이제 화면 어느 곳을 터치해도 `drilldownCoreId` 또는 `activeId` 모달이 정상적으로 닫힙니다.
3. **Android 하드웨어 Back 버튼 문제 (Path 3)**: 기존의 단순 `useEffect` 안의 `BackHandler`를 Expo Router의 `useFocusEffect`와 `useCallback`으로 감싸, 네비게이션 스택과 Android 14 Predictive Back 제스처 간의 충돌을 방지하고 정상적으로 모달을 닫도록 수정했습니다.
4. **스와이프 닫기 제스처 추가 (Path 4)**: `NodeSheet`, `DataNodeSheet`, `DrilldownSheet`에 전용 `GestureDetector`(`Gesture.Pan`)를 감싸 수직 하단 스와이프를 감지하도록 구현했습니다. `activeOffsetY(10)`로 터치 이벤트를 시트가 흡수하게 하여, 시트 위에서 스와이프 시 뒤쪽의 지도가 함께 움직여 덜컥거리는 현상(map-fight)을 원천 차단했습니다.

### 커밋:
- 레포: `_worktrees/2ndB-antigravity`
- 커밋: `7442958 fix(graph): resolve NavGraph modal transitions, tap-outside bounds, hardware back button, and swipe-to-close conflicts`

리뷰 및 본 브랜치 머지 부탁드립니다.
