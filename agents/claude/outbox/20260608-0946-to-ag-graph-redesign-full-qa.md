---
type: work_request
from: claude
to: antigravity
date: 2026-06-08 / 09:46 KST
lane: device QA (Antigravity 전담)
priority: P1
ref_images: agents/claude/refs/main-graph-reference-20260608.png · main-graph-reference2-drilldown-20260608.png
---

# 그래프 트리 재설계 전체 device QA (P1-P11 머지됨, main 0cbf5b7)

Simon 레퍼런스대로 메인 그래프를 **하단뿌리 상향 크리스탈 테서랙트 트리**로 재설계 완료(4-AI 방향). 에뮬레이터(Pixel_9_Pro_XL)에서 레퍼런스 2장과 대조 QA 부탁. (Claude adb 불안정 → AG 전담.)

## 검증 (현재 main, USE_V3_ART=true)
1. **구조(P1)**: Soul Core가 **하단-중앙 뿌리**로 내려오고 5 Pattern Core 큐브가 **위로 2-2-1 canopy**, 데이터가 위로 가지치는가? (전엔 중앙 radial.) 뿌리가 하단 인사이트 카드 **뒤로 안 가리는지**(카드 framing).
2. **눈송이(P7/P4)**: 홈 화면에서 파란 눈송이 데이터가 **상시 보이는가**(전엔 zoom 1.8+에서만). tier-3 서브메뉴는 숨겨졌는가.
3. **크기/색(P2/P5/P3)**: 큐브가 크고 데이터 작은 위계, 링크 **전부 시안**(green/violet 없음), Soul Core 주황 불꽃 없는지(시안 연꽃만).
4. **글로우(P6)**: 모든 노드 뒤 시안 발광 블룸이 **Android에서 보이는가**(shadowRadius 무시되면 disc opacity로 충분한지 — 안 보이면 disc opacity 올려야 함).
5. **카드(P9)**: 하단 2 카드 = 세컨비 리포트 + 코어 스포트라이트(큐브 아이콘+코어명). '아콘가' 같은 조사 깨짐 없는지.
6. **모션(P11)**: 트렁크 고요·잎 흔들림 자연스러운가. **시스템 reduced-motion 켜면** 드리프트/펄스/스폰 정적인가.
7. **크래시 회귀(#251)**: 노드 탭→모달/시트 열고닫기 반복 크래시 없는지.

## 보고
- outbox에 갭 + 스크린샷(가능시) + 레퍼런스 대비 일치도/어긋난 점. Claude가 다음 반복 반영.
- 특히 **Android 글로우 가시성**과 **뿌리-카드 framing**이 device에서 의도대로인지 중점.

## 펀치리스트 (이미지, 코드 외)
- `public/assets/tesseract-v10/narrative_core.png`가 wisdom_core와 같은 파랑 → 은색/문화이트 재틴트 필요(5코어 색 구분). 이미지 편집 가능하면 부탁.
