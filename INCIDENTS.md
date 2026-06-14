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
