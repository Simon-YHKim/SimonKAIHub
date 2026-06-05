---
owner: claude
note: "이 파일은 Claude(오케스트레이터)만 작성한다. Codex·Antigravity는 읽기 전용."
last-updated: 2026-06-06 02:48:00 KST
---

# BOARD.md — 마스터 상태판 (always-latest)

> 전체 작업의 단일 진실 소스(single source of truth). Claude가 갱신.
> Codex·Antigravity는 세션 시작 시 이 파일로 현재 상황을 파악한다.

## 🔥 진행 중 (In Progress)
| ID | 작업 | 담당 | 상태 | 비고 |
|---|---|---|---|---|
| cycle-2 | 2nd-B **UX 완벽화 사이클** — 10커밋 green, Codex 95/100 상승중 | claude | executing | branch `claude/cycle-2-concept-consistency` @`65e5ac4`. HTML `agents/claude/outbox/preview/20260606-cycle2-progress.html` |
| cycle-1 | 2nd-B 완성형 사이클 — **머지 완료** (PR #211, main `0bfbfa3`) | claude | ✅ done | 보안·trust·route·Android네이티브·a11y |
| research-2 | deep-research: 사람을 정확히 파악하는 구조(SOKA·informant·표현적글쓰기·ESM·LLM) | claude | 실행중 | → "구조" 설계 culminating 산출 |

## 📥 분배됨 / 대기 (Assigned / Waiting)
| ID | 작업 | 요청→담당 | 상태 | 메시지 |
|---|---|---|---|---|
| disp-codex2 | MBTI 강등 스펙 + DESIGN 판정 + 모바일 오버플로우 스펙 | claude→codex | ✅ done | 회수 완료, 구현 반영중 |
| user-grok | 나이대별·국가별 X 선호/유입/트렌드 10+cycle 딥다이브 | **user**→grok | 진행/완료 | §10.4 user-direct (`85d1322`) |
| user-android | Android 10+ 심층 검사 리포트 (part 1·2) | **user**→? | 진행 | §10.4 user-direct (`1582810`,`e4722b5`) |

## 👥 멤버 온보딩 상태
| AI | 역할 | 상태 | 런타임 |
|---|---|---|---|
| Claude | 오케스트레이터 + 코딩 | ✅ active | Claude Code |
| Codex | 이미지 · UI/UX | ✅ onboarded | codex CLI (헤드리스 OK) |
| Antigravity | 안드로이드 네이티브 검수 | ✅ onboarded | **gemini CLI**(헤드리스 작동) / agy CLI(헤드리스 hang—첫 인증 필요) / IDE(수동) |
| Grok | X(소셜) 트렌드·소비자 리서치 | ✅ onboarded | grok CLI (`--prompt-file` UTF-8, 헤드리스 작동) |

## ✅ 완료 (Done) — 최근 10건
| ID | 작업 | 담당 | 완료 |
|---|---|---|---|
| disp-codex | 화면 인벤토리·IA 감사: 43라우트 분류 + Phase6 화면맵 + DESIGN 위반 후보 | codex | 2026-06-05 |
| disp-grok | 소비자·경쟁 리서치(7제품 감정 + Barnum + portable hook + 권고5) | grok | 2026-06-05 |
| disp-antig | 네이티브 QA 준비도: 조건부 가능(Reanimated v4/RN0.85 리스크) + QA 체크리스트 | antigravity | 2026-06-05 |
| audit-wf | 7차원 코드감사 → 8건 확정(0C/0H/5M/3L): knowledge_sources RLS 인젝션·DDL drift·wiki export PII·마스코트 canon | claude | 2026-06-05 |
| deepres-wf | 심리토대 문헌(Big5/SDT/Attach/VIA) 24 claim 수집(검증레이어 장애→C8 인간검증 대상) | claude | 2026-06-05 |
| status-check | 4-AI 허브 라이브 점검(3-AI 헤드리스 핑 OK: Codex/GPT-5·Gemini·Grok4.3) + 2ndB ff-only 동기화 | claude | 2026-06-05 |
| protocol-v10 | PROTOCOL §10(실행모드·자동승인·Claude단독대화·병렬·직접지시/현황) + `*-activate.md` 3종 추가 | claude | 2026-06-05 |
| onboard-codex | Codex 허브 온보딩 + self-commit 실증 | codex | 2026-06-05 |
| onboard-antig | Antigravity(gemini) 허브 온보딩 + self-commit 실증 | antigravity | 2026-06-05 |
| boot-0 | 3-AI 통신 프로토콜·구조 생성 | claude | 2026-06-05 |

## 🧱 블로커 / 결정 대기 (Blocked / Decisions)
- **consent 법무 카피 사인오프** (2nd-B cycle-2) — ConsentNotice placeholder + `LEXICON_LAST_LEGAL_REVIEW=null`. 런치 게이트, Simon/법무 결정 필요.
- **런타임 device 증명** (2nd-B cycle-2) — AG Gradle 8.13 에뮬 빌드 성공, 스크린샷 수급 중(Codex 100점 요건).

## 📌 활성 프로젝트
| 프로젝트 | 레포 | 경로 | 단계 |
|---|---|---|---|
| **2nd-B** | github.com/Simon-YHKim/2nd-B (main, 138 br) | `projects/2nd-B/` | build |
| _TEMPLATE | — | `projects/_TEMPLATE/` | 템플릿 |
