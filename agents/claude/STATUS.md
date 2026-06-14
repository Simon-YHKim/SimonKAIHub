---
agent: claude
role: orchestrator + coding + online-git + merge-gate
updated: 2026-06-14 10:33:42 KST
state: running
---

# Claude — STATUS

[2026-06-14 / 10:33:42 KST] [Claude] 허브 시스템 전수 감사 + 개선. 모니터/데몬 업그레이드, expo-smoke·wiki-ingest 신규, AG 죽은 gemini 데몬 정지. 2nd-B 25건 라이브(main 39f9592).

- **허브 진단(Simon 4문)**: ① 모니터 가시성 부족 ② 구조적 idle ③ 에뮬/expo 디버깅 실태 ④ context-reset/wiki/loop-learning 자동화 부재.
- **발견된 문제**: AG(gemini)=429 QUOTA 8h 死인데 10분마다 헛spawn / 데몬 사이클당 1태스크+백오프無 / Codex 프로세스 누수(~10~22) / 모니터에 활성수·작업중·≥3적체 미표시 / wiki 교훈 12건 미ingest.
- **개선(라이브)**: ① monitor.ps1 = procs·WORKING/idle·**pend>CL(Claude 마지막커밋 이후 AI커밋수)·≥3 RED 알람**·에뮬상태·데몬수 ② hub-daemon.ps1 = 429 백오프(지수, ~8h 캡)+기본10분+옵션 드레인 ③ **expo-smoke.ps1**(LLM無 adb logcat 크래시 스캔, 에뮬 PASS 확인) ④ **wiki-ingest.ps1**(교훈 수집→Claude ingest 다이제스트) ⑤ AG 죽은 데몬 정지.
- **2nd-B 25건**: r29 auth judge-mode(39f9592) 등. 정책/i18n 3/3 PASS, `.order()` 데이터셰이프 전수 클린.
- **게이트(Simon)**: 수익화/법무/secrets/임상. D-17 Lever B 빌드 GO 대기.
