# ROUTING.md — 역할 분장 & 라우팅 표

> 누가 무엇을 책임지는가, 그리고 경계를 넘는 일이 생기면 누구에게 요청하는가.
> 변경은 Claude가 세 AI 합의 후 갱신(§ PROTOCOL 1).

---

## 1. 역할 (lane)

### 🟦 Claude — 메인 지시 AI · 코딩
- **오케스트레이션**: 사용자 요청 접수 → 분해 → 분배 → 통합 → 보고. `BOARD.md` 단독 관리.
- **코딩**: 구현, 비즈니스 로직, 아키텍처, API, 빌드 스크립트, 테스트(TDD), 리팩토링, git 운영.
- 산출물: 소스코드, 테스트, 빌드 결과, 기술 결정 문서.

### 🟨 Codex — 이미지 · UI/UX
- **디자인/비주얼**: 이미지 생성·편집, 아이콘, 일러스트, 에셋.
- **UI/UX**: 화면 레이아웃, 컴포넌트 디자인, UX 플로우, 인터랙션 명세, 디자인 토큰/시스템.
- 산출물: UI 스펙(md), 에셋 파일 경로, 디자인 토큰, 레이아웃 가이드, (필요 시) 목업.

### 🟩 Antigravity(Gemini) — 안드로이드 네이티브 검수
- **네이티브 검증**: Android 네이티브 빌드 검증, Gradle/매니페스트/권한 점검, 네이티브 모듈.
- **디바이스 QA**: 실기기/에뮬 동작 검수, 크래시·ANR·성능(프레임·메모리) 점검, 회귀 확인.
- 산출물: QA 리포트(md, pass/fail + findings), 재현 절차, 로그 경로, 개선 요청.

---

## 2. 라우팅 표 (경계 넘는 작업 → 담당에게 request)

| 일이 생김 | 담당 | 요청 방향 |
|---|---|---|
| 화면 구현하려는데 디자인/레이아웃 필요 | Codex | Claude → Codex |
| 이미지/아이콘/에셋 필요 | Codex | Claude → Codex |
| UX 플로우·인터랙션 정의 필요 | Codex | Claude → Codex |
| 코드 구현·로직·버그 수정 | Claude | Codex/Antigravity → Claude |
| 디자인을 코드로 구현 | Claude | Codex → Claude |
| 네이티브 빌드/디바이스에서 검수 | Antigravity | Claude → Antigravity |
| QA에서 버그 발견 → 코드 수정 | Claude | Antigravity → Claude |
| QA에서 UI/디자인 문제 발견 | Codex | Antigravity → Codex (또는 경유 Claude) |

> 애매하면 **Claude(오케스트레이터) 경유**가 기본. Claude가 BOARD에 올리고 적절한 담당에게 분배.

---

## 3. 표준 흐름 예시 (앱 화면 1개)
1. 사용자 → Claude: "로그인 화면 만들어줘"
2. Claude → Codex (request): 로그인 화면 UI/UX 디자인 요청 (`Acceptance`: 레이아웃 + 토큰 + 상태별 정의)
3. Codex → Claude (response): UI 스펙 md + 에셋 경로
4. Claude: 스펙대로 구현(코드) → BOARD 갱신
5. Claude → Antigravity (request): 네이티브 빌드 + 디바이스 QA 요청
6. Antigravity → Claude (response): QA 리포트(pass/fail, findings)
7. Claude: findings 반영 → BOARD done → 사용자 보고
