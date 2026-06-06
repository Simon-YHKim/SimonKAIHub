# PROPOSAL_QUEUE.md — 실행가능 큐 (PROTOCOL §25)

> Claude 단독 관리. AI 제안 백로그(132 gate + AG 33 + Grok 24 + proposal 7)를 병렬 트리아지(wf wdze15wze, 152분류)해 테마로 dedup한 큐.
> 버킷: **A.Claude즉시 / B.Codex디스패치 / C.AG디스패치 / D.Simon·external**. 매 사이클 상위 doable 소진 → verify(gated) → push → 완료체크.
> generated: 2026-06-06 21:50 KST · 소스 SHA-regate들은 같은 블로커를 반복 → 테마로 통합.

## 제외 (이미 머지됨 — git log 교차대조)
- data-truth false-empty 3종: `/insights`·`/core-brain`·`/trinity` sources 집계 → **머지 완료** (gate 093848·100749·114119은 stale).
- segmented/PremiumButton `accessibilityState` 병합, assessment Likert 시맨틱 → 머지됨.
- expo-crypto HIBP(D-04), AppState 토큰 refresh perf → 머지됨.
- a11y 라벨 대량(전 화면), preauth/permissions/formats jargon 일부, retired-route(#214 부분), privacy monotonic 코어(#215) → 머지됨.

---

## A. Claude-doable-now (검증가능·device무관·내 lane)
| # | 테마 | 파일 | value | status |
|---|---|---|---|---|
| A1 | **Raw error → product-tone copy + recovery** (실패경로 11화면) | account·capture·wiki·inbox·interview·settings·records 실패 핸들러 | high | open |
| A2 | **Privacy 토글 진실** — 8스위치 중 external_analytics만 enforce, 7개 phantom | `src/app/privacy.tsx` (+enforcement 코드) | high | open |
| A3 | **Privacy failed-opt-out fail-closed** — #215가 실패세이브 revert 커버하는지 검증, 미흡 시 guard+test | `src/lib/privacy/analytics-consent-queue.ts` | high | open |
| A4 | **Auth loading-aware guards** — signin/signup guest guard + complete-profile redirect가 loading 무시 → 잘못된 화면 flash | `src/app/(auth)/sign-in,sign-up,complete-profile.tsx` | high | ✅ **머지 `3ee8885`** (InlineLoader guard, sign-up guest guard 신설) |
| A5 | **Data export scope 진실** — export 약속(파일) vs 실제(clipboard) 불일치 통일 | support·data·settings·wiki | high | open |
| A6 | **Theme native 영속** — native에서 localStorage만 써 영속 안 됨 → AsyncStorage 또는 컨트롤 숨김 | `src/lib/theme/ThemeContext.tsx` | high | ✅ **머지 `1a688c6`** (web 동기경로 유지 + native AsyncStorage 하이드레이트/쓰기) |
| A7 | **Persona assessment-only summary** — audit 없을 때 LLM summary 생성(날조) 차단 | `src/lib/persona/build.ts` | high | ✅ **머지 `1335fc4`** (rows>0 게이트 + 정직한 빈메시지 + 테스트, paid call도 절약) |
| A8 | **Crisis badge 가독성** — hotline badge 10→12px (안전표면) | `src/components/safety/CrisisRouter.tsx` | high | ✅ 이미 `fontSize:12` 적용됨 (stale gate) |
| A9 | **Account DOB auth refresh** — DOB 저장 후 minor state 미갱신 | `src/app/account.tsx` | high | ✅ **머지 `55b6a8e`** (AuthContext additive refresh() + DOB저장 후 호출, safety-routing 정합) |
| A10 | **내부용어→사용자언어** (로직 문자열) — RLS/RAG/LLM/[[slug]]/frontmatter | permissions·inbox·wiki·settings·insights | high | open (Codex와 분담) |
| A11 | Spinner-only → PremiumLoadingState | audit·profile·record/[id] | med | ✅ **머지 `0dfa75a`** (라우트 로딩 3화면, profile 인라인 spinner는 적정 유지) |
| (alert-load) | alert-only load error → 지속 에러상태(false-empty 방지) | research·insights | high | ✅ **Codex 머지 `f74efc1`** (research·insights). trinity 남음 |
| A12 | Destructive busy-escape — busy 중 sign-out/nav 비활성화 | `src/app/settings.tsx` | med | ✅ **머지 `db31d6f`** (Sign out busy 가드 + 지속 배너 screen-reader 알림) |
| A13 | Inbox 'View in wiki' → 정확한 slug 페이지 | `src/app/inbox.tsx`·`wiki.tsx` | med | open |
| A14 | Records source row → 특정 source detail 라우트 | `src/app/records.tsx` | med | open |
| A15 | Wiki delete → stale promoted source 리셋 | `src/lib/wiki/queries.ts` | med | ✅ **머지 `d9e73db`** (markSourceNotIngested + deleteWikiPage source 리셋 + 테스트2) |
| A16 | Quant-intro storage flicker → tri-state | `src/components/quant/QuantIntroModal.tsx` | med | open |
| A17 | Dynamic-type clipping — numberOfLines 반응형 | 전역(22×1줄·10×2줄) | med | open |
| A18 | Web zoom/focus — user-scalable=no 제거 + focus-visible | viewport·Pressable | med | open |
| A19 | Import analysis fallback 공개 | `src/app/import.tsx` | med | open |
| A20 | Record detail assessment raw JSON → friendly | `src/app/record/[id].tsx`·`persona/evidence.ts` | med | open |
| A21 | Retired-route helpers 잔여(/journal·/imagine·/mbti emit) | `src/lib/village-ui.ts`·`persona/evidence,self-portrait.ts` | med | open(부분) |
| A22 | **GTM/마케팅 docs** (Grok X신호) — docs/GTM.md + i18n trust signals + core 명칭 직관화 | docs·locales·DESIGN.md | high(마케팅) | open |
| A23 | LOW: capture stale journal lock 제거, source emdash, post97 microtype | capture·ConsentNotice·NavGraph | low | open |

## B. dispatch-Codex (UI/UX·i18n·anti-slop·이미지)
- **i18n 번들 이관** (915 inline locale 분기 → 번들) ← 이미 redirect(20260606-212300). 신뢰·법무 카피 우선.
- 카피 jargon: ✅ **capture-input `707387e`** + ✅ **jarvis-citation + manual-onboarding `20794de`**(Codex). 남은: theme-contract(Light 실제구현)·pixel-font→readable.
- 공유 컴포넌트: ✅ **PreferenceToggle 머지 `d741f5a`**(privacy·formats 토글 통합). 남은: LikertScaleQuestion·ExternalLinkButton/CopyAction·ActionChip primitives.
- **feedback-alert-contract** (61 Alert.alert → PremiumToast/Modal) — 🟢 진행(assessment `20794de` + import/esm `19adcf9` + wiki export `9055cae` + wiki action/sign-in `a9d19ad`), 나머지 화면 계속.
- 공유 컴포넌트: ✅ PreferenceToggle `d741f5a` + ✅ consent checkbox `9055cae`(Codex). 남은: LikertScaleQuestion·ExternalLinkButton/CopyAction.
- formats dead CTA(mock)·settings crew-density phantom·route-ia-numbering·design-token drift(74 hex/rgba).
- reduced-motion·contrast-ledger(Light palette).
- a11y P3 long-tail: image·modal-overlay·form-input·onboarding-dots·pressable-interaction.
- expo-image resizeMode→contentFit(6파일)·temp script 정리.
- §19 그래프빌리지 비주얼 패스(AG perf 교차검증 대기).

## C. dispatch-AG (Android/네이티브/perf/멀티모달 perf-side) — **동결해제, 생산 중**
- ✅ **머지 `707387e`**: KeyboardAvoidingView(account·audit·data·settings·support)·CAMERA권한+LivingAsset AppState guard·phantom notification 행 제거.
- 남은(device 증명 필요): Android 키보드 **에뮬 증명**(7화면)·FlatList 런타임 증명·NavGraph resume/drift 증명·OCR 권한/프리뷰 증명·D-10 알림 하드닝(POST_NOTIFICATIONS·Doze)·§19 그래프빌리지 perf-side(프레임/OOM).
- ⚠️ **AG는 copy/i18n 중복생산 금지**(capture jargon은 Codex가 커버) — 네이티브 lane 고수.

## D. Simon / external (§15 안전레일 — 합의 우회 불가)
- **consent legal readiness** — placeholder 법무카피→확정본+versioning (D-03).
- **deployment env 진실** — FORCE_TIER/ENABLE_*/LLM_MODE 기본값 확정 (D-01).
- **social provider 실설정** (D-05).
- ~~permissions phantom notification~~ — ✅ **AG가 행 제거 머지 `707387e`**(expo-notifications 미구현이므로 phantom 행 삭제가 정답). 해소됨.
- go-live freeze 상태 명확화.

---

## E. UX 자연스러움·직관·정보위계·자산일관성 (페르소나 시뮬 §26)
> 페르소나-UX 워크플로(wv5i3ngxx, 연령10밴드×직업+자산+모션) **264 발견**. 전체: `agents/claude/persona-ux-findings-20260607.json`.
> 유형: non-intuitive 87·a11y 47·hidden 42·overload 42·stiffness 31·asset 15. 담당: codex 190·claude 33·ag 34·simon 7.
> ⚠️ **소득구간·문화/국가 축은 확장 시뮬에서 추가**(아래 진행).

| # | 테마 | 담당 | sev | status |
|---|---|---|---|---|
| E1 | **capture 정보과잉** — 5모드(journal/memo/link/ocr/file)+트랙+해시태그 동시노출. 최다 공통지적 → 기본 1모드 + 고급 '더보기' 점진공개 | claude(상태/기본모드)+codex(탭/시각) | high | open |
| E2 | **비직관 라벨/카피** — "영차영차 던지기"/"Send to the cells", 모드 아이콘만(텍스트 없음) → 직관 동사 + 아이콘 텍스트 라벨 | codex | high | open |
| E3 | **a11y 라벨 누락** — 아트(IslandArt·SecondBSprite·authHero)·NavGraph 노드에 accessibilityLabel/role 없음(스크린리더 빈화면) | codex | high | open |
| E4 | **네이티브 접근성·터치** — 터치타깃 ≥44/48px·hitSlop·입력 48px·텍스트 16px(고령)·EyeIcon 영역. NavGraph 제스처→버튼 계층탐색. 에뮬 증명 | ag | high | open |
| E5 | **hidden 발견성** — settings 진입점 없음→NavGraph floating settings(ag). wiki export 묻힘→주요액션 승격(codex) | ag+codex | high | open |
| E6 | **NavGraph 초보자 모드** — tier1-2만 먼저+단계공개+첫방문 가이드+노드 설명 라벨 | claude | high | open |
| E7 | 평가도구 Likert 고령 접근성 — 세로배열·큰버튼·16px·끝점 라벨 | codex | med | open |
| E8 | **stiffness 31건** — 전환·press 피드백·로딩 등장 부드럽게(즉각 cut 제거), 부드러운 ease | ag(perf)+codex(스타일) | med | open |
| E9 | **자산 일관성 15건** — 네이밍 혼재·버전접미사(v1/v3/final/candidate)·스타일 혼합·미사용 정규화 | codex+claude | med | open |
| E10 | settings 전체삭제 확인 — typed 'DELETE'는 의도된 안전마찰 → 제거 대신 카피 명확화만(전체wipe는 typed 유지) | claude review | low | open |
| E11 | 미래기능 비전 7건 — 협업/공유·이미지 스튜디오 등 → '곧 옴'/숨김 | simon | — | open |

### E (확장) — 소득구간 × 문화/국가 (페르소나 시뮬 w7nuzgtiy, 190발견)
> 전체: `agents/claude/persona-ux-findings-expand-20260607.json`. 차원: income 98·culture 92. 유형: non-intuitive 54·trust-privacy 39·pricing-payment 32·cultural-fit 24·locale-i18n 18·overload 13. 담당: codex 94·**simon 65**·claude 16·ag 15.

| # | 테마 | 담당 | sev | status |
|---|---|---|---|---|
| E16 | **데이터 사용량 힌트** — OCR/File 데이터 비용·Wi-Fi 권장(저사양·선불폰·데이터민감) | ag | high | open |
| E17 | **온보딩 메타포 추상성** — 조각/마을/그래프/노드/신경망이 저학력·번역 시 불명확 → 구체 시나리오 카피·3단계 축약 | codex | high | open |
| E18 | **신뢰/프라이버시 카피** — consent 국외전송('Google에 뺏긴다' 오독)·민감내용 동의 불신 → 안심 카피(암호화·비열람·법규준수), 문화별 차등 | codex | high | open |
| E19 | **locale-i18n(18)** — 영어 혼용 레이블(long_term_memory 등)·해당언어 부재 폴백 노출·통화 표기 | codex | med | open |
| E20 | **RTL·중동** — 아랍어 RTL 레이아웃·이슬람 가치·gender·종교 달력 | codex(레이아웃)+ag(네이티브 RTL) | med | open |
| E21 | **OAuth provider 시장별** — KR=Kakao/Naver·JP=LINE·글로벌=Google/Apple 가용 gating(D-05 연계) | simon+ag | med | open |
| E22 | **cultural-fit(24)** — 자기성찰/저널링 수용성·톤(존댓말/겸손/관계중심)·종교/가족/집단주의 카피 적응 | codex | med | open |

### 🔴 Simon 수익화 결정 필요 (65 simon 항목 통합 — §15 external·business)
> 시뮬이 드러낸 **수익화 시스템의 구체 갭**(Simon 수익화 고도화 목표 직결). 가격·결제는 비즈니스+실비용이라 **Claude 단독 결정 불가 → Simon 승인 후 구현**.
- **M1 가격 투명성**: soma/cortex/brain 가격·요금제 화면이 어디에도 없음 → `account.tsx`에 PricingCard/요금제 섹션. **가격(KRW/USD) 확정 필요**.
- **M2 무료티어 관대함**: journal 2개 제한이 핵심가치(패턴/AI) 경험 전 차단 → empty state만 봄. 무료 1회 AI 맛보기 or 한도 재설계. **티어 정책 결정**.
- **M3 결제수단/PG**: Stripe(신용카드)만으론 저소득·KR·글로벌 배제 → 토스/카카오페이/휴대폰결제/UPI/Pix/모바일머니 + 원타임/소액/선불 옵션. **PG 선택**.
- **M4 구독 모델·피로**: 단일 구독부터(soma)·업셀 피로 방지·티어 트레이드업·광고지원 여부(저소득 수용성). **모델 결정**.
- **M5 신뢰 인증**: SOC2/암호화 등 신뢰 시그널(법무·인증 실행). 카피는 Codex(E18), 인증은 Simon.
> 결정되면 Claude가 티어 게이팅·요금제 화면·결제 플로우 구현. 그 전엔 무료티어 한도 도달 시 **막다른길 제거**(행동경로 안내)만 저위험 선제 가능.
