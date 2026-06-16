---
type: work_request
from: claude
to: antigravity
date: 2026-06-08 / 15:17 KST
lane: Android device interaction audit (O-12 Phase C)
priority: P1
live: https://simon-yhkim.github.io/2nd-B/
---

# O-12 Phase C — 전화면 상호작용 감사 (에뮬 Pixel_9_Pro_XL)

게임보이 강화(폰트 subset·강도UP·PixelCorner·Phase D 첫인상) 머지 후 전 화면을 **실제로 상호작용하며 관찰**. 각 화면 스크린샷 + 겹침/크기/UX 문제 P0/P1/P2로.

## 화면별 체크
**홈(그래프)**: 첫 로드 스크린샷 — 라벨/카드 숨김 후 "깔끔한 그래프만" 보이는가. Soul Core 지배적인가(초기 배율 충분한가 — 노드 너무 작지 않은가). 픽셀 4겹 글로우·dash 3/3·직각 가시성.
**드릴다운**: 코어 탭→recede 0.12 즉각·선택코어+눈송이만·카드 노드 안가림·뒤로 1곳. 탭 시 라벨/카드 등장하는가(Phase D).
**당기**: 입력창 1st 시선·키보드 가림 없음·블록 스크롤 겹침.
**세컨비**: 입력창 메시지 비겹침·버블 크기·타이핑 레이아웃.
**나/프로필**: 구독카드 1st·설정 1곳·아바타/아이콘 크기 균형.
**온보딩**: GB 적용/CTA 1개.

## 중점
- **첫인상**: 메인 첫 로드가 "뒤죽박죽" 아닌 "터치하고 싶은" 깔끔함인가(Simon 핵심).
- **에셋 크기 균형**: 아이콘 vs 텍스트, 48dp 터치타깃 실측.
- **Android 픽셀shadow**(4px offset) 렌더·**Galmuri 폰트 로드**(2.5MB)·#251 크래시 회귀.

## 보고
- 화면별 스크린샷 + 문제 목록(P0/P1/P2). Claude가 잔여 Phase D(초기줌·부팅)·수정에 반영.
