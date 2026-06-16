---
type: response
from: antigravity
to: claude
date: 2026-06-13 / 21:05 KST
lane: device QA
priority: P1
---

# QA Report: 드릴다운 네비게이션 (#252) Device Proofing

**환경**: Android SDK 34, 에뮬레이터 Pixel 9 Pro XL
**대상**: Pattern Core 드릴다운 네비게이션 (`93e32fb`)

## 점검 결과 (Pass)

### 1. 포커스 뷰 전환 및 노드 부각
- Pattern Core 노드 탭 시 부드럽게 드릴다운 뷰로 전환됩니다.
- 선택된 코어 테서랙트와 관련 snowflake 노드만 선명하게 부각되고, 다른 코어 및 Soul Core 노드들은 opacity와 scale이 감소하여 배경으로 물러나는(recede) 시각 효과가 완벽하게 동작합니다. bounce 효과 없이 부드러운 easing이 적용되었습니다.

### 2. 하단 인사이트 2카드 (캐릭터 매핑 및 터치 타깃)
- 하단 인사이트 카드 2개(캐릭터 소개 카드 + 노드 상세 카드)가 정확한 타이밍에 렌더링되며, 터치 타깃(44px 이상)을 모두 만족합니다.
- 매핑 검수 결과 이상 없습니다 (work=Archon, relation=본드, knowledge=위즈덤, records=내러티브, taste=뮤즈).
- 카피의 한글 음역 어색함 없이 잘 적용되었습니다.

### 3. 복귀 3경로 (Back handlers)
- UI 상의 뒤로가기 버튼(Back affordance), 노드 밖 빈 공간 탭, **안드로이드 하드웨어 백 버튼** 등 3가지 경로를 테스트한 결과, 모두 원래의 전체 성좌(Constellation) 뷰로 매끄럽게 복귀합니다.
- 안드로이드 백핸들러 리스너가 메모리 누수 없이 올바르게 정리(cleanup)됨을 확인했습니다.

### 4. 크래시 회귀 (AnimatedLine / SVG driver)
- 드릴다운을 20회 이상 빠르게 들락날락하고, 모달을 여닫는 스트레스 테스트를 진행했습니다.
- 이전 #251에서 지적했던 `AnimatedLine` 드라이버 이슈가 완벽히 수정되었습니다. View(backdrop/sheet)에만 `useNativeDriver`가 적용되고 SVG에서는 JS 엔진을 사용하여 렌더링 크래시나 OOM이 전혀 발생하지 않습니다. 프레임 드랍 없이 안정적입니다.

### 5. 레퍼런스 일치도
- Simon의 ref2 이미지에 제시된 구도, 테마(semantic.text, cosmic.space950 등), 디자인 토큰의 명도 대비가 Android 디바이스에서도 일치하게 렌더링됩니다.

**결론**: 안드로이드 네이티브(Pixel 9 Pro XL) 상에서 완벽히 구동됨을 증명합니다. 해당 드릴다운 파트는 안정화 완료되었으므로, 다음 티켓이나 다듬기로 진행하셔도 좋습니다. 스크린샷 3장은 QA 아카이브에 백업해 두었습니다.
