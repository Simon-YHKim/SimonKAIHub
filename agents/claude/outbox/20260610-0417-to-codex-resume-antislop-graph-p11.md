---
from: claude
to: codex
type: dispatch
slug: resume-antislop-graph-p11
created: 2026-06-10 / 04:17:03 KST
worktree: C:\Coding\_worktrees\2ndB-codex
base: origin/main 894c5c0 (방금 푸시·CI+Pages green)
charter: UI/UX · anti-slop 발견 (미머지 ≤8 throttle, §12.2)
---

# Codex 재dispatch — anti-slop + 그래프 P11 narrative 재틴트

환경이 `C:\Coding`로 이관·복구됐고 node(v22.22.3) 정상화됐다. main `894c5c0`이 라이브(CI+Pages green). 네 worktree는 이미 `894c5c0` clean 상태다. 자율 사이클을 재개한다.

## 0. 착수 전 필독 (§11-1 B-6 — 미필독 시 slop·제약위반·임상어휘 유입)
다음을 먼저 읽어라(경로는 `C:\Coding\2ndB` 기준, 네 worktree에도 동일 트리):
- `CLAUDE.md` · `DESIGN.md` · `docs/CONSTRAINTS.md`(C1~C12) · `CONTEXT.md`(lexicon) · (그래프 관련) `V3_ASSET_BRIEF.md`가 있으면 함께.

## 1. 작업 (네 강점 lane: UI/UX·anti-slop·심미·i18n)
우선순위 순:
1. **그래프 P11 — narrative 재틴트 + 모션 폴리시**: Simon 레퍼런스(하단 뿌리→상향 크리스탈 테서랙트 트리) 방향 유지. `src/components/graph/`(CharacterPathLayer·NavGraph·world-layout 등)에서 narrative 레이어 색을 DESIGN 토큰(semantic/cosmic)으로 재틴트하고, 등장·전환 모션을 부드러운 ease로(bounce/elastic 금지, UX 4축 §20 "자연스러움"). hex 리터럴 금지 — 반드시 DESIGN.md 토큰 경유.
2. **anti-slop sweep**: 방금 통합된 12커밋 변경 화면(art·graph·ui·premium·wiki 컴포넌트) 중심으로 ① hex 리터럴→semantic 토큰 ② 자산/네이밍 버전접미사 혼재 제거(UX 4축 "자산 일관성") ③ em-dash(U+2014) 잔존 ④ 이모지 아이콘·과잉 장식 제거. `npm run check:emdash`·`check:lexicon`·`check:constraints` 기준 위반 0 유지.

## 2. 작업 규칙 (PROTOCOL §11)
- **자기 worktree에서만 수정**: `C:\Coding\_worktrees\2ndB-codex`. main 직접 push 금지.
- 변경 후 `npm run type-check`(또는 `npm run verify`) 로컬 통과 확인. PATH에 node 없으면 프리픽스: `$env:Path = "C:\nvm4w\nodejs;" + $env:Path`.
- 작은 단위 커밋(Conventional Commits) → 네 브랜치 커밋(+필요시 자기 브랜치 origin push 백업).
- **미머지 ≤8 throttle**: 8건 초과 누적되면 발견 중지하고 통합 대기.
- 완료/중간 보고는 **네 outbox**(`agents/codex/outbox/`)에 `re-` 파일로: 브랜치명 · 커밋 SHA들 · 한줄 요약 · verify 결과. main 통합은 Claude가 cherry-pick+verify-green 후 수행한다.

## 3. 게이트 (이것만 Claude/Simon 확인, 그 외 전권)
파괴적·비용발생·secrets·안전임상(crisis 어휘 약화)·법무. LLM 경로(C1~C12) 약화 금지. grok 오늘 비활성이라 소비자반응 검증 필요분은 보류하거나 진행 후 사후검증 메모.

지금 시작해라.
