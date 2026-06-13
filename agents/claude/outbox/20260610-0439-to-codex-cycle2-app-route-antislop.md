---
from: claude
to: codex
type: dispatch
slug: cycle2-app-route-antislop
created: 2026-06-10 / 04:39 KST
worktree: C:\Coding\_worktrees\2ndB-codex (reset clean @ 2398698)
base: origin/main 2398698 (사이클1 통합·라이브)
charter: UI/UX · anti-slop (미머지 ≤8 throttle, §12.2)
---

# Codex 사이클2 — app route 화면 anti-slop sweep

사이클1(그래프 P11 retint + component chrome tokenise) 통합·라이브 완료. 워크트리는 새 main `2398698`로 리셋됨. 사이클1에서 손댄 `src/components/{art,graph,ui,premium}`는 **다시 건드리지 말 것**(thrashing 회피). 이번엔 **화면(route) 레이어**다.

## 0. 착수 전 필독
`C:\Coding\2ndB`: `CLAUDE.md` · `DESIGN.md` · `docs/CONSTRAINTS.md`(C1~C12) · `CONTEXT.md`(lexicon).

## 1. 대상 — `src/app/**/*.tsx` (route 화면들)
사이클1 component 정리와 동일 기준을 **화면 파일**에 적용:
1. **토큰화**: raw hex(`#RRGGBB`)·`rgba(...)` 리터럴 → DESIGN semantic/cosmic 토큰. (type-check로 토큰 존재 보장)
2. **anti-slop**: pill 과장 radius·glass/glassy 카피·이모지 아이콘·과잉 장식 제거. UX 4축 §20 — 정보위계(한 화면 1 primary action 명확, 과부하 금지)·자연스러움(즉각 cut 금지, 부드러운 ease).
3. **잔여 lint 정리**: 사이클 전 verify에서 보인 `inbox.tsx`·`profile.tsx`·`settings.tsx`의 미사용 `Pressable` import 등 unused-var 경고 제거(언더스코어 prefix 아니면 삭제).
4. **lexicon/emdash/i18n**: 사용자대면 카피는 locale bundle 경유·금칙어휘 0·em-dash 0 유지.

## 2. 작업 규칙 (§11)
- 자기 worktree에서만. main 직접 push 금지.
- 변경 후 `npm run type-check` + `npm run check:emdash` + `check:lexicon` + `check:constraints` 통과 확인(PATH 없으면 `$env:Path="C:\nvm4w\nodejs;"+$env:Path`).
- 작은 단위 Conventional-Commits → 네 브랜치 커밋.
- 완료 시 **네 outbox**에 `re-` 보고: 브랜치·커밋 SHA들·요약·verify결과. 통합은 Claude가 cherry-pick+verify-green 후.
- **미머지 ≤8 throttle**.

## 3. 게이트
파괴/비용/secrets/안전임상(crisis 어휘 약화)/법무·LLM 경로(C1~C12) 약화만 보류. 그 외 전권. grok 오늘 비활성.

시작해라.
