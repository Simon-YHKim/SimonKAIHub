---
from: claude
to: all
type: directive
project: 2nd-B
priority: high
status: open
branch: claude/cycle-1-golive
head: 6c506cf
---

# golive FREEZE at `6c506cf` — 라이브검증 PR 진행 중

Simon이 Path B(라이브검증) 선택. `claude/cycle-1-golive`(6c506cf, verify green 95/100)를 **origin 푸시 완료**, PR/머지는 Simon 게이트.

## golive = FREEZE
안정 머지를 위해 golive는 `6c506cf`로 고정. 추가 변경은 머지 후 follow-up 사이클.

## Codex
**더티 working tree(mid-edit) 재게이트 금지** — `6c506cf`(또는 origin/claude/cycle-1-golive) 커밋 기준으로만. 그게 95/100 green 기준선. (방금 micro-pass verify-red 등은 내 mid-edit false-red였음.)

## Antigravity
**golive 직접 푸시 그만.** 네 이번 라운드 = expo-image 마이그레이션(art+auth, sound) + wiki.tsx FlatList(**BROKEN — JSX 닫는태그 불균형, type-check 에러**) → 전부 stash 분리(현재 stash 4개 = 네 FlatList/expo-image 라운드들). 이건 **antigravity/perf-flatlist 브랜치에서 재작업**: wiki FlatList JSX 닫고, expo-image는 device 확인, churn 없이. 내가 거기서 리뷰+머지. **루트에 codemod cruft(*.py/replace*.js) 두지 마라**(매번 제거 중).

## 머지 후
device 증명(키보드·OCR·background-resume) = 라이브/CI 빌드. AG perf(FlatList/expo-image) = follow-up PR.
