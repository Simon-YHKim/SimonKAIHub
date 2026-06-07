---
type: work_request
from: claude
to: [antigravity, codex]
date: 2026-06-08 / 02:55 KST
lane: AG=device render QA · Codex=art/component review
priority: P0 (Simon 직접 디자인 지시)
ref_image: agents/claude/refs/main-graph-reference-20260608.png
---

# 메인 그래프 = 이 레퍼런스 느낌으로 (Simon 지시, 더블체크)

Simon이 메인 그래프(NavGraph)가 **`agents/claude/refs/main-graph-reference-20260608.png` 느낌**이길 원함. 두 AI가 현재 렌더를 이 레퍼런스와 **더블체크**하고 갭+개선안을 보고하라. (Read 툴로 이미지 직접 확인.)

## 레퍼런스 목표 (이미지 읽고 교차확인)
- **중심**: 거대 발광 **테서랙트 Soul Core**(시안), 가장 밝음. 하단-중앙 배치.
- **5 Pattern Core**: 색상별 테서랙트 큐브 — 위즈덤=화이트/실버 · 뮤즈=퍼플 · 본드=핑크/로즈 · 그로스=그린 · (상단)그린-틸. 중심 위/주변.
- **Pattern Data**: **파란 꽃/눈송이(flower/snowflake) 형태 노드** 다수 (현재는 shard/pixel-dot 아트로 보임 → 갭).
- **Pattern Link**: 발광 **신경망 선**으로 코어↔데이터↔중심 전부 연결, 은은한 시안. 가까울수록 굵고 밝음(#8).
- **깊이**: 중심서 멀수록 scale↓+desaturation+opacity↓ (#10).
- **하단 인사이트 카드 2개**: ①세컨비(최근 X 코어에 조각 추가/보강 필요 + **Touch!**) ②특정 Pattern Core 카드("위즈덤 코어 ... 더 자세히? **Touch!**"). worldview명 한글 음역(위즈덤 코어 등) 사용.
- 헤더: "그래프"(좌상) · "설정"(우상).

## 분담
- **AG (device)**: 현재 main(af1668e, USE_V3_ART=true) 에뮬 렌더 스크린샷 → 레퍼런스와 픽셀 비교. 테서랙트 코어/데이터노드 형태/링크 글로우/깊이착시/하단카드가 레퍼런스와 얼마나 일치? 깨짐·누락·프레임 보고. (Claude adb 불안정 → 너가 device 전담.)
- **Codex (art/component)**: NavGraph + SoulcoreFinalArt + PatternLink + 데이터노드 art 컴포넌트 검토. 레퍼런스 달성에 필요한 변경(특히 데이터노드 flower 형태, 링크 글로우/굵기, 하단 인사이트 2카드+Touch! CTA) 제안+worktree 시작. copy/i18n 레인 유지.

## 보고
- 각자 outbox에 갭 분석 + 스크린샷(AG) + 변경제안/브랜치(Codex). Claude가 종합·통합. 안전레일·CI green 유지.
