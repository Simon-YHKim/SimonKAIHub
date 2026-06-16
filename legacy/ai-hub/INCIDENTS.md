---
owner: claude
note: "append-only 인시던트 원장. 와치독(§5/§13)·복구 작업이 한 줄씩 추가. 정본 복구절차=RUNBOOK.md, 정본 규칙=PROTOCOL.md."
last-sync: 2026-06-14
---

# INCIDENTS.md — 허브 인시던트 원장 (append-only)

> 무인 운용 중 발생한 장애·복구를 시간순으로 한 줄씩 남긴다. 형식:
> `[YYYY-MM-DD / HH:MM:SS KST] | 신호 | 원인 | 복구 | 재발방지`
> 반복 3회+ 패턴은 SimonKWiki 교훈(§18)으로 승격하고 여기에 링크.

## 로그
- [2026-06-14 / 13:30:00 KST] | SETUP | RUNBOOK/INCIDENTS 신설(허브 개선 패스) | n/a — 와치독·복구 표면 신설. monitor/hub-health는 신호 생산만 했고 'responder'가 없었음(BACKLOG #5) | RUNBOOK 룩업표 + 와치독 듀티(ROUTING Grok)로 신호→대응 연결
- [2026-06-15 / 08:21:00 KST] | 데몬 중복(각 AI 2개=6, 03:22+03:23 이중런치) | HUB-STARTUP 모드A/런처에 중복 spawn 가드 없음 → cycle 중복·git race | 디렉터가 즉시 후발 PID kill(각 1개=3) | hub-daemon.ps1에 lane(-Only)별 named-mutex 단일인스턴스 가드(중복이면 exit 0). RUNBOOK §데몬중복
- [2026-06-15 / 08:21:00 KST] | codex STATUS.md 118KB 비대(§28 size-guard 통과) | commit.ps1 size-guard가 모든 .md 일괄 256KB → STATUS도 미만이면 통과 | codex 단일라이터가 STATUS 절단+gitignored *.log 회전(directed task 발행) | commit.ps1에 STATUS.md 전용 64KB 캡(초과 시 SIZE FAIL). RUNBOOK §STATUS비대
- [2026-06-15 / 08:21:00 KST] | .watchdog-state.json UTF-8 BOM(hub-health FAIL) | hub-watchdog.ps1 Set-Content -Encoding utf8 → PS5.1에서 BOM 추가 | 기존 BOM .NET ReadAllText→WriteAllText(no-BOM) 제거 | hub-watchdog write를 [IO.File]::WriteAllText+UTF8Encoding($false)로 교정. FAIL=0 확인
- [2026-06-15 / 08:21:00 KST] | outbox frontmatter 225/1761 malformed(WARN) | 초기 메시지가 frontmatter 키 contract 전 작성 | 점진 정리(신규는 contract 준수) | 필수키 contract를 PROTOCOL/RULES에 명확화(후속). 비차단 WARN 유지
- [2026-06-15 / 08:26:00 KST] | claude(실행자) STATUS.md stale(06-14) | /loop 사이클 STATUS 1줄 갱신 step 누락 | 실행자 STATUS 현행화(O-13/14/15) | §12 루프 step "매 사이클 STATUS 1줄" — 이 갱신으로 이행
