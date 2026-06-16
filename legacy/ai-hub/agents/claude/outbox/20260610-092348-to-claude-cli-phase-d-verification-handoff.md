---
from: claude (Cowork 데스크톱)
to: claude (원격 CLI 세션)
type: handoff + findings
created: 2026-06-10 / 09:23:48 KST
---

# ORDERS 실행권 이양 수용 + Phase D 검증 결과 인계

[2026-06-10 / 09:23:48 KST] d95a227 공지 확인·수용. 내 ORDERS 실행 cron(007d4bdc)은 삭제했고, 모니터 전용 틱(d325f199, 10분: 허브 인박스 + 터널/Tailscale 헬스 + 읽기 전용 충돌 감시)으로 재편성했다. 원격 제어 모드 동안 2nd-B 코드 작업 착수 안 함.

## 인계: 이양 직전 틱(09:15~09:21)에서 수행한 O-12 follow-up Phase D 코드 검증 결과

ORDERS.md에는 쓰지 않았다(채널 이양 후라). 필요하면 ORDERS_REMOTE DONE에 편입해라.

1. **파워온 sweep ✅ 스펙 일치**: `src/components/premium/PowerOnOverlay.tsx` — 180ms 시안 스캔라인 + 120ms 페이드, reduced-motion 생략, 세션 1회.
2. **순차 등장 ✅ 구현됨(스펙 문자값과 상이)**: NavGraph spawn — 로고 620ms 후 노드당 130ms·tier 간 110ms·reveal 320ms (스펙: tier 시작 0/150/300/450ms). 6/8 감사에서 "Phase D 첫인상 양호" 기판정 → 현행 유지 권장. Simon이 더 스냅하게 원하면 조정.
3. **초기 줌 ⚠ 스펙-아키텍처 모순**: 스펙 "Soul Core 상단 40%"는 하단뿌리 상향 트리 재설계(world-layout `ROOT_ANCHOR y=0.82`)와 정면 모순. 현행 NavGraph.tsx:751-769 = targetY `height*0.6`·scale 1.5 (하단-중앙 지배). **권장: 현행 유지, 상단 40% 문구 폐기** — Simon 한 줄 결정 필요 사항으로 ORDERS_REMOTE에 올려두면 좋겠다.
4. **파일 위생**: ORDERS.md 5~453줄에 과거 오더 본문이 헤더 블록쿼트 안에 중복 붙어 있음(붙여넣기 사고로 추정). 아카이브 정리 시 참고.

## 데스크톱 측 상태 (참고)

- Tunnel `soha` Connected(서비스 등록, 재부팅 생존) · Tailscale `100.76.82.42` · gh 인증 OK.
- RDP: 설정은 전부 켜졌으나 Win11 함정으로 rdp-tcp 리스너 미기동 — Simon 복귀 후 Settings 토글 OFF→ON 또는 재부팅 필요 (펀치리스트).
- AC 전원·절전 해제 확인 — 세션·터널 유지에 문제 없음.
