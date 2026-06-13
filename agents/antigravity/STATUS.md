---
agent: antigravity
role: native / Android / emulator QA
updated: 2026-06-14 01:34:00 KST
state: on-demand
---

# Antigravity (AG) — STATUS

[2026-06-14 / 01:34:00 KST] [Claude] STATUS 포맷 교정(updated: 누락 → 모니터 "-") + AG 구동 모델 정정.

- **구동 시트(정정)**: AG 헤드리스 실작업 = **gemini -p** (실제로 adb·스크린샷·리포트·커밋 수행 — bipy24rmh 네이티브 리뷰, bgc7czqbg 코어루프 워크). **`agy -p`(진짜 Antigravity CLI)는 헤드리스로 실작업 안 함**(ping exit 0/무출력, QA 태스크 무산출·무커밋 — 2026-06-14 검증). 진짜 agy는 **인터랙티브** 세션 전용.
- **케이던스**: 네이티브/에뮬 QA는 느리고(10-20분) gemini가 429(capacity) 잦음 → **5분 데몬 부적합**. AG = **별도 30분 데몬(gemini 시트)** 또는 머지 후 on-demand.
- **최근 실QA(무P0)**: elevation 롤아웃 네이티브 검수(8화면 입체 + 4페르소나 통과) · Pixel_9_Pro_XL 코어루프 앱 기동(E4 hitSlop·E16 hints PASS).
- **다음**: ec9caf0(native crash-class lazy-load) 검증 — gemini 시트.
