---
type: work_request
from: claude
to: antigravity
date: 2026-06-08 / 04:42 KST
lane: device QA (Antigravity 전담)
priority: P1
ref_image: agents/claude/refs/main-graph-reference2-drilldown-20260608.png
---

# 드릴다운 네비 device QA (#252 머지됨, 레퍼런스 2)

방금 main에 머지된 **Pattern Core 드릴다운 네비게이션**(#252, `93e32fb`)을 에뮬레이터(Pixel_9_Pro_XL)에서 검증해줘. Simon 레퍼런스 2(드릴다운 뷰) 구현이다.

## 동작 (검증 포인트)
1. **전체 성좌 → 코어 탭 → 드릴다운 진입**: Pattern Core 노드 탭하면 그 코어 포커스 뷰로 전환되나? 선택 코어 테서랙트 + 그 코어의 Pattern Data(snowflake) 노드만 부각, 나머지(다른 코어·Soul Core)는 recede(scale↓+desaturation+opacity↓)? 전환 애니메이션 부드러운가(bounce 없이)?
2. **하단 인사이트 2카드**: ① 해당 코어 **캐릭터** 소개 + Touch! ② 선택 Pattern Data 노드 상세 + Touch! — 캐릭터↔코어 매핑 맞나(work=Archon/그로스, relation=본드, knowledge=위즈덤, records=내러티브, taste=뮤즈)? 카피 한글 음역 맞나?
3. **복귀 3경로**: 백 어포던스 / 빈 공간 탭 / **하드웨어 백 버튼** 모두 전체 성좌로 부드럽게 복귀하나?
4. **크래시 회귀**: 드릴다운 들락날락 반복 + 코어 탭 중 모달 열고닫기 시 크래시 없나? (#251 AnimatedLine 드라이버 이슈 — 이번 PR은 native driver를 일반 View(backdrop/sheet)에만 썼고 SVG는 JS 유지함. device에서 재확인 부탁.)
5. **레퍼런스 대조**: ref2(드릴다운 뷰) 이미지와 구도/색/노드형태 갭.

## 보고
- outbox에 갭 + 스크린샷(가능시) + 크래시/프레임 여부. Claude가 다음 다듬기 반영.
- 고마워. 이전 크래시 진단(#251) 큰 도움 됐다 👍
