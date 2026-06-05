---
from: claude
to: all
type: fyi
project: 2nd-B
priority: high
status: open
branch: claude/cycle-3-hardening
---

# [FYI] cycle-3 적대적 버그 헌트 결과 + 펀치리스트

밤샘 자율작업. 8 서브시스템 적대적 버그헌트(find→skeptic verify→synthesis, 17 에이전트) → 42발견 → 검증후 **P0:0 / P1:3 / P2:11 / P3:13**. 전체: `agents/claude/outbox/20260606-cycle3-bughunt-synthesis.md`.

## 지금 수정 중 (cycle-3, 안전·고가치 18건 — fix 워크플로우)
P1 3: crisis_events 레저 누락(gemini.ts routeCrisis)·계정삭제 "데이터 그대로" 오표시(account.tsx)·소스브리프 미갱신(wiki.tsx).
P2/P3 안전건: persona 이중빌드+미성년 핫라인 게이트, core-brain 에러무시, inbox 재시도캐시, privacy 토글 레이스, complete-profile 동의 연령밴드, safety mergeResults fail-closed, chat 프롬프트인젝션 가드, persona Big5 인터뷰오염, import 더블탭/클립보드, index reduced-motion, LoadingScreen 더블 onContinue, Quant 타이머/렌더부작용, daily-prompts KST자정, 저널 streak 20캡.

## ⚠️ Simon 결정/보류 (펀치리스트 — 코드로 자력해결 안 함)
1. **`EXPO_PUBLIC_FORCE_TIER` 기본값 `"brain"`(페이월 전면 개방)** — 코드 주석도 "런치타임 결정"이라 명시. judge/release 빌드 전 `off`로 전환할지 + 누가 게이트 소유? **무감독 변경 안 함**(judge 데모 동작 바뀜).
2. **HIBP(유출비번) 네이티브 fail-open** — `crypto.subtle` 미존재 시 무력화. 진짜 수정은 폴리필 의존성(expo-crypto) 추가 필요. 미성년 비번 강제가 런치 필수인가? (의존성+미성년 정책 = Simon).
3. **계정삭제 카피** — 즉시 오표시는 수정 중이나, GDPR/개인정보보호법 "삭제권" 문구는 법무 리뷰 권장.
4. **crisis_events 레저** — 레저 쓰기는 수정 중이나, 미성년 위기개입 보고/주의의무 의존 여부는 Simon 확인.
5. **보류(무감독 회피)**: NavGraph 3건(perf-churn/edge — 방금 만진 복잡파일, 감독 패스 필요), chat quota 타이밍(과금 영향).

수정 verify+커밋 후 Codex 재게이트 → green/고득점이면 PR. @codex 대기 부탁.
