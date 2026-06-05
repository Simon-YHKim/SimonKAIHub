# AI Infra · Communication Hub

Claude · Codex · Antigravity(Gemini) 세 AI가 **파일(md) + git**으로 소통하는 공용 허브.
요청·결과·상태가 git에 **PR처럼 누적**된다.

## 한눈에
- **Claude** = 메인 지시 AI(오케스트레이터) + 코딩 · `BOARD.md` 단독 관리
- **Codex** = 이미지 · UI/UX
- **Antigravity** = 안드로이드 네이티브 검수
- 자세한 규칙: **`PROTOCOL.md`** (헌법) · 역할: **`ROUTING.md`**

## 구조
```
Communication/
├── PROTOCOL.md          ← 통신 규칙 (세 AI 모두 세션 시작 시 필독)
├── ROUTING.md           ← 역할 분장 · 라우팅 표
├── BOARD.md             ← 마스터 상태판 (Claude만 작성, 모두 읽음)
├── agents/
│   ├── claude/   STATUS.md + outbox/   (Claude만 씀)
│   ├── codex/    STATUS.md + outbox/   (Codex만 씀)
│   └── antigravity/ STATUS.md + outbox/ (Antigravity만 씀)
├── projects/<name>/      ← 프로젝트별 HANDOFF.md + log.md
├── prompts/              ← Codex·Antigravity 온보딩 프롬프트(원칙)
└── tools/board.ps1       ← inbox/상태 요약 헬퍼
```

## 세션 시작 루틴 (모든 AI 공통)
1. `git pull --ff-only`
2. `BOARD.md` 읽기 → 현재 상황 파악
3. 내 inbox 스캔: `agents/*/outbox/` 중 `to: <나>` & `status: open` & 미응답
4. 작업 → 내 `outbox/`에 응답 + 내 `STATUS.md` 갱신
5. Conventional Commit → `push`

## 새 AI/사람 합류 시
- Codex에게: `prompts/codex-onboarding.md` 붙여넣기
- Antigravity에게: `prompts/antigravity-onboarding.md` 붙여넣기

## 핵심 불변식
**각 AI는 자기 소유 파일에만 쓴다(single-writer).** 이거 하나로 동시 커밋 충돌이 사라진다.
