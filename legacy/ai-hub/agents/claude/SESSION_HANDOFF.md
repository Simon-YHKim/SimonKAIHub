# SESSION HANDOFF — 2nd-B 원격 오더 + 자율 루프 (2026-06-10 09:05 KST)

> 이전 세션(Opus 4.8 하브 오케스트레이터)이 새 세션으로 인계. 새 세션은 이 파일을 읽고 아래 "이어가기 프롬프트"대로 즉시 가동.

## 지금 상태 (사실)
- **main = `aab6e16`** (= `e1cc258` + Cowork PONG 커밋 1개). origin == local 동기. **CI green, Pages 라이브**.
- **node** `C:\nvm4w\nodejs\node.exe` v22.22.3 · **gh** `C:\Program Files\GitHub CLI\gh.exe` 2.93.0. ⚠️ **stale-PATH**: 매 PowerShell 첫 줄에 `$env:Path = "C:\nvm4w\nodejs;C:\Program Files\GitHub CLI;" + $env:Path` 필수(레지스트리는 정상, 띄운 터미널이 PATH수정 전 시작).
- **verify 903 green**(`cd C:\Coding\2ndB; npm run verify`), lint 0.
- **프로덕션 Supabase** 동기: 이번 세션이 0041·0042·0043 마이그레이션 적용(MCP `mcp__claude_ai_Supabase__apply_migration`, project_id=`zoacryukmdeivmolvyhj`). RLS self-grant 2건 + 안전 3건 클로즈·익스플로잇 시뮬+적대리뷰 검증.
- codex/AG 워크트리 미통합 0. **agy = quota 소진(오늘 AG 불가)**. **grok 오늘 제외**. codex anti-slop 수렴.

## ⚠️ 듀얼-Claude 충돌 주의 (중요)
- ORDERS를 보는 세션이 **둘**: 이 인계 세션 + **데스크톱 Cowork-Claude(Fable 5, 로컬 cron)**. 둘 다 실행하면 BOARD 단독작성 위반·ORDERS/BOARD race·main 중복 push.
- **Simon에게 실행 주체 확인 후 한쪽만 BOARD/ORDERS 씀.** 미확정 시 ORDERS.md/BOARD 쓰기 보류, Monitor(읽기)만.

## 오더 채널
- **`C:\Coding\2nd-B\ORDERS.md`** (정확히는 `C:\Coding\2ndB\ORDERS.md`, GitHub Simon-YHKim/2nd-B main).
- Simon이 `## OPEN` 밑에 새 블록 push → 감지 → 실행 → `## DONE`에 `[YYYY-MM-DD / HH:MM:SS KST]` 피드백. **OPEN 최상단의 06-08 O-12 follow-up은 구 오더(미정리)라 재실행 X — 새 블록만 라이브.**
- ORDERS.md 편집 전 `git fetch`+ff(Simon 동시편집 가능).

## 안전레일 (이것만 Simon 확인, 나머지 무확인)
파괴 · 비용발생 · secrets · 안전임상(crisis/safety) · 법무. main 통합은 `npm run verify` green + CI green 별도확인 후. 명시 경로만 `git add`(git add -A 금지). 커밋 본문 따옴표·em-dash 금지.

## 허브
- BOARD/CONTROL/PROTOCOL/ORDERS = `C:\Coding\AI Infra\Communication\`. BOARD=Claude 단독. CONTROL state=running. 내 inbox=`agents/claude/inbox`. 허브는 로컬 git(origin 없음).
