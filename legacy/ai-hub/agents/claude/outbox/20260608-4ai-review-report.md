# O-11 4-AI 리뷰 리포트 — 게임보이 UI 오버홀 (PR #266-#277)

작성: 2026-06-08 / Claude 합성 (Claude·Codex·Grok 완료 / AG device QA 진행)
대상: O-7 터치 ~ O-9/10 게임보이 ~ IA. 라이브: simon-yhkim.github.io/2nd-B

## 게이트 결과
- **Codex(코드)**: 초기 FAIL → **P1 회귀 수정 완료(#277)**. 이제 PASS 동등. #251 크래시 회귀 없음(AnimatedLine SVG props useNativeDriver:false 유지 확인), 타입오류·신규 any 없음, 888 tests green.
- **Claude(디자인 정합)**: PASS. 4-tier 128/82/38/30 유지·변경화면 하드코딩색 0·gameboy-tokens cosmic 매핑.
- **Grok(전략/a11y)**: WCAG AA **전부 PASS**(gb-ink 16.69·accent 10.25·power 14.30·amber 13.67:1, P0 a11y 없음).
- **AG(device)**: QA 의뢰됨(에뮬 8체크+스크린샷) — 회신 시 추가 반영.

## P0 (크래시/접근성 차단) — **없음** ✅

## P1
1. ✅ **[수정완료 #277] surfaces caller-style 순서 회귀**(Codex): Phase2에서 공유 컴포넌트가 caller style을 base보다 앞에 놓아 화면별 오버라이드 무력화 → caller 뒤로 복원(press/focus는 그 뒤 유지).
2. ⚠️ **[Simon 결정] Galmuri11 폰트 5.25MB**(Grok): 번들 비대, XPRIZE web 데모 초기로드/TTI 악영향. 권고: ①fonttools/glyphhanger로 subset(~300KB) ②web font-display:swap+preload ③기존 NeoDunggeunmo(650KB)로 대체 검토. **어느 방향?** (subset 권장 — Simon 폰트 선택 유지하며 90%↓.)
3. 🔧 **dashed 1px 비-GB 잔재**(Grok): capture modeMoreTab·wiki TemplateEditor drop zone가 1px dashed → GB 2px 언어와 충돌. (그래프 엣지 dash는 의도된 Phase3.) → 후속 통일 커밋.
4. ⚠️ **[Simon 결정] 게임보이 "toy 인상" 리스크**(Grok): XPRIZE 심사(교육/인간잠재력)에 GB가 가벼워 보일 수 있음, 특히 온보딩. 권고: 온보딩/empty/error에 `framed` prop으로 GB-exempt(soft) 옵션 + "이 콘솔은 생각을 담는 도구" anchoring copy. **GB 강도 정책(on/soft/off) 정하실지?**

## P2 (polish, 자율 진행)
- pixel-physical steps() easing 미구현(duration만) — 스택 전환 linear/steps 보강 + 테스트(Codex).
- 테스트 갭: NodeGlow·pixel-physical·surfaces style-merge·card UI 통합.
- 로딩 ActivityIndicator → 픽셀 dot-matrix 로더. empty/error orb 튜닝.
- DESIGN.md "Phase1=tokens only, 컴포넌트 미수정" 문구가 실제(컴포넌트 전면 GB)와 불일치 → 문서 갱신.
- ORDERS.md trailing whitespace(git diff --check) — 문서 위생.
- gameboy-tokens border raw rgba → withAlpha(cosmic.signalBlue,0.35) (Claude P2 nit).

## 결론
오버홀 품질 양호 — P0 없음, 유일한 게이트-FAIL(surfaces 회귀)은 즉시 수정·머지. **Simon 결정 2건**(Galmuri subset 방향 / GB 강도 정책)만 주시면 나머지 P1·P2는 자율 진행. AG device 회신으로 Android 픽셀shadow·폰트로드·48dp 실측 보강 예정.
