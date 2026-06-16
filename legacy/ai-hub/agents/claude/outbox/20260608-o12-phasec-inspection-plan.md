# O-12 Phase C UI Inspection Plan (Workflow)

Verification confirms both functional P1s (home overlap: `index.tsx:479` gate + `zIndex:24` at `:665` + both CTAs literally "Touch!" at `:505`/`:525`; secondb double graphic: `SceneHero` `:331` + `SecondBSprite size=96` `:409` both render when `!hasTurns`). Synthesis below.

---

# O-12 Phase C — 통합 우선순위 FIX LIST (5화면 종합)

## 0. 한 줄 요약
크래시(P0) 없음. **상호작용을 실제로 깨뜨리는 P1은 4건**(홈 시트 가림 / 세컨비 그래픽 2개 / 설정 24개 벽 / 캡처 깨진 카드모양). 나머지 대부분은 **단일 근본원인 = 화면 로컬 StyleSheet가 `gameboy-tokens`를 우회**하는 cross-cutting 이슈로, 한 번의 토큰 교체 커밋으로 5화면 동시 해결 가능.

---

## 1. P0 (크래시/블록) — 즉시
**없음.** 5화면 전부 크래시·진입 불가 이슈 미발견.

---

## 2. P1 (가림/오클루전/깨진 상호작용/첫인상) — 다음 커밋, 각 fix 포함

### P1-1 · 홈/그래프 — insight 카드가 모든 bottom sheet 액션을 덮음
- **위치**: `src/app/index.tsx:479` (게이트 `!showingEmptyGraphCard && graphTouched`), `:665` (`zIndex:24`), `:483` (`bottom ~104`). 시트는 NavGraph 내부 `NavGraph.tsx:2437`(bottom 92)/`:2470`(78)이고 카드 스택은 `index.tsx`의 형제라 양수 zIndex가 NavGraph 서브트리 전체 위로 그려짐 → 첫 탭 직후 `NodeSheet`/`DataNodeSheet`/`DrilldownSheet`의 `살펴보기`/`Ask`/`새 관점으로 펼치기` 버튼을 가림.
- **Fix**: NavGraph에서 `activeId`/`drilldownCoreId` 변화를 `onActiveChange(sheetOpen)` 콜백으로 올려, 스택을 `graphTouched && !sheetOpen`일 때만 렌더. 이미 `CharacterPathLayer`/`CrewLayer`가 쓰는 `hidden={activeId != null}`(`NavGraph.tsx:1884`,`1887`) 패턴 그대로 미러.

### P1-2 · 세컨비 — 첫 화면에 SecondB 그래픽 2개 동시 렌더
- **위치**: `src/app/secondb.tsx:331` (`SceneHero` island+worker, `!hasTurns`) **AND** `:409-414` (`SecondBSprite size={96}`, `turns.length === 0`). 둘 다 SecondB → "화면당 그래픽 1개" 위반, 뒤죽박죽.
- **Fix**: SceneHero가 이미 worker를 들고 있으므로, `turns.length === 0` 빈 상태의 96px 스프라이트(`:408-415`)를 제거하고 `t("empty")` 카피만 남김.

### P1-3 · 설정 — 24개 컨트롤 벽 + 인라인 파괴 CTA 9개
- **위치**: `src/app/settings.tsx:343-642`. nav 7 + theme 2 + crew 4 + **파괴 버튼 9개**(`:453-488`,`:495-532`,`:539-576`) + 전체삭제 input(`:596-616`) + 로그아웃. primary action 부재 + 우발 삭제 위험. 게다가 같은 페이지가 링크하는 `/data`·`/records`(`:372-382`)와 삭제 기능 중복.
- **Fix**: 설정을 1-depth nav 허브(7개 nav 행)로 축소, 부분/전체 삭제는 전부 `/data`+`/records` 하위로 이동, theme/crew는 각자 행으로 접기(progressive disclosure).

### P1-4 · 캡처 — savedPanel/proposalPanel "둥근 카드 위 픽셀코너" 깨진 모양
- **위치**: `src/app/capture.tsx:1264-1279` — `PremiumCard`에 `style`로 `borderRadius: radii.md`+`borderWidth:1`를 전달, `PremiumPanel`이 caller style을 마지막에 적용(`surfaces.tsx:79-86`)해 GB의 radius0/2px를 덮어 **둥근 카드**가 되는데 `PixelCorner` 브래킷(sharp-corner 가정)은 그대로 그려져 **둥근 모서리에 픽셀 코너 마커가 붕 뜬 깨진 비주얼**. 사용처 `:596`,`:618`.
- **Fix**: 두 패널의 `borderRadius`/`borderWidth` override 제거(색만 지정) 또는 `pixelCorners={false}`.

---

## 3. P2 (폴리시)

- **홈 두 카드 CTA 동일 라벨 "Touch!"** — `index.tsx:505`,`:525` (경쟁 primary 2개). 둘째 카드 CTA 라벨/웨이트 강등 또는 한 번에 한 카드.
- **홈 fetch `.catch` 없음** — `index.tsx:286-316`. 실패 시 빈 그래프도 에러 UI도 안 뜸(`hasAnyPiece` null 고착). `.catch`로 에러 플래그 + 온브랜드 재시도.
- **홈 첫 진입 빈 카드가 dim 모달** — `index.tsx:415-427` (`emptyGraphBackdrop` absoluteFill, `zIndex 100`). 시트 패턴으로 정렬 권장(규칙은 modal-over-content 금지).
- **캡처 본문 입력 픽셀 고정폭** — `capture.tsx:1366` `fontFamilies.mono` → 장문 한국어 가독성 저하. `readable`로.
- **캡처 에러 피드백 PremiumModal** — `capture.tsx:1112-1140`. inline/bottom-sheet로.
- **세컨비 composer가 상단** — `secondb.tsx:303-313` (읽기는 하단). 키보드 처리 이미 돼있으니 하단 이동 검토.
- **세컨비 인트로 모달** — `secondb.tsx:531-575` 콘텐츠 위 fade 모달. reference drawer(`:578-616`)와 동일 bottom-sheet로.
- **온보딩 progress dot 둥금** — `onboarding.tsx:233-234` `borderRadius:4` → `gameboy.radius`(0).
- **온보딩 dead-code 잔재** — `onboarding.tsx:249-262` `secondBFrame`(radius 32 + soft glow + rgba 리터럴, DESIGN.md 위반) + `village`/`villageRow`(`:175-186`,`:242-248`) 도달 불가(`STEPS`는 welcome/trust/firstShard만). 삭제.
- **온보딩 마지막 스텝 skip 중복** — top Skip(`:134`)과 secondary "건너뛰고 둘러보기"(`:155-162`) 둘 다 `finishToGraph`. `isLast`일 때 top Skip 숨김.
- **온보딩 trust 4 스프라이트 클러스터** — `onboarding.tsx:198-209` (worker 64 + ShardArt 76×3). worker 제거 또는 합성 1 에셋.
- **`PremiumLoadingState` ActivityIndicator** — `feedback.tsx:131` 부드러운 스피너, reduced-motion 무시. 깜빡이는 픽셀 글리프로(reduced-motion 게이트).
- **SceneHero 셸 non-GB** — `SceneHero.tsx:314`(`radii.lg`),`:319`(soft glow shadowRadius 18),`:427`(`radii.sm`). 공유 fix.

---

## 4. CROSS-CUTTING (여러 화면 동일 원인 → 공유 fix 1개)

### CC-1 · 모든 화면 로컬 StyleSheet가 `gameboy-tokens`를 우회 (가장 큰 단일 근본원인, P1-visual)
공유 프리미티브(`surfaces.tsx`/`feedback.tsx`/`Input.tsx`)는 GB 마이그레이션 완료됐으나 **각 화면 파일이 직접 짠 스타일은 구 `radii.*`(=8 rounded) + `borderWidth:1` + `pixelShadowStyle` 없음 + `PixelCorner` 없음**. 같은 화면에서 sharp 픽셀 컨트롤 옆에 둥근 카드가 섞여 "반쯤 마이그레이션" 느낌.
- 홈: `index.tsx:672-674`(insightCard radius8/border1), `:614`,`:649`,`:723`,`:732`; `NavGraph.tsx:2439-2447`(sheet radius8+soft shadow),`:2550-2557`(a11yBtn pill),`:2365-2372`,`:2400-2407`,`:2527`. (※ `index.tsx`/`NavGraph.tsx`는 `gameboy` **import 자체가 없음**.)
- 캡처: `capture.tsx`도 `gameboy` import 없음 — 주 CTA `tossBtn`(`:1433-1442`, Pretendard 라벨 `:1448`) + 거의 모든 카드/칩/탭. 한 탭 줄에서 `modeMoreTab`만 GB(`:1342-1348`)·`modeTab`은 rounded로 규칙 혼재.
- 세컨비: 로컬 스타일 `secondb.tsx:625-815` 전부(bubble `:794`, modeChip `:685`, quickChip `:764`, composerPrimary `:648`, modalCard `:721`, drawer `:775`).
- 프로필: `profile.tsx` `gameboy` import 없음 — subscriptionCard(`:224`,`:221`), planIcon(`:236`), settingsButton(`:214`), quickChip(`:252`).
- 설정: `settings.tsx`는 import만 하고 색 1곳(`:69`)만 사용 — SettingsActionButton(`:735-736`), section(`:720`), 버튼 라벨 Pretendard(`:771`, variant 없는 `<Text>` `:99`).
- **공유 Fix (1커밋)**: 각 화면에서 `gameboy`/`pixelShadowStyle` import → `borderRadius:radii.* → gameboy.radius`(0), `borderWidth:1 → gameboy.borderWidth`(2), border color → `gameboy.border`, soft shadow → `...pixelShadowStyle()`. 가능한 카드/버튼은 `PremiumCard`/`PremiumPanel`/`PremiumButton`로 교체. chrome 라벨 fontFamily → `fontFamilies.pixelKo`(특히 `settings.tsx:771`, `capture.tsx:1448`).

### CC-2 · 인터랙티브 컨트롤 <48dp 산재 + 시스템 근본원인
- 시스템 근본: `surfaces.tsx:479` `PremiumButton btn.minHeight:44` → **44→48** 한 줄로 앱 전역 버튼 해결(온보딩 primary CTA·모든 state action 포함).
- 개별: 홈 `emptyGraphCta minHeight:44`(`index.tsx:650`), `resetBtn`(`NavGraph.tsx:2395-2408`); 캡처 `tossBtn ~44`(`:1433`), `trackChip ~42`(`:1304`), `tagChip ~40`(`:1049`/`:1390`), `tagAddChip 36`(`:1401`); 세컨비 Clear `~34`(`secondb.tsx:288-300`), quickChip `~34`(`:512`/`:760`), 그라운딩 strip `~20`(`:466`/`:743`); 프로필 quickChip `44`(`:177-184` hitSlop 없음); 온보딩 Skip `~34`(`onboarding.tsx:134-142`, 스텝1-2 유일 탈출구 → 접근성 P1성); 설정 full-wipe Input `46`(`Input.tsx:48`).
- **공유 Fix**: `surfaces.tsx:479` 48로 + 나머지 칩/토글/링크에 `minHeight:48` 또는 `hitSlop={{top:16,bottom:16,left:12,right:12}}`. `Input.tsx:48` 46→48.

### CC-3 · modal-over-content (규칙 "새 요소는 bottom-sheet/transition")
- 캡처 `capture.tsx:1112-1140`, 세컨비 `secondb.tsx:531-575`, 설정 `settings.tsx:651`,`:678`(`PremiumModal`), 온보딩 advisory(`feedback.tsx:74-105` 콜사이트). `CrisisRouter`(capture `:1142`)는 안전 예외라 유지.
- **공유 Fix**: 비-차단 confirm/error/intro 흐름을 `PremiumBottomSheet`(`feedback.tsx:16/54-69`)로 이전. `PremiumModal`은 진짜 차단 시스템 다이얼로그에만.

---

## 5. 이미 잘 된 것 (GB + Phase D 첫인상 안착 확인)
- **Phase D 첫인상 OK**: 콜드 로드 시 라벨/카드 숨김(`NavGraph.tsx:1831-1838`, `index.tsx:479`), Soul Core 우세 초기 줌 `scale 1.5`(`NavGraph.tsx:702-720`), power-on 재생(`index.tsx:572`). 뒤죽박죽 아님.
- **티어 위계 정확**: 128/82/38/30(`NavGraph.tsx:303-306`), 에셋 크기 균형 양호(5화면 SIZE BALANCE 대부분 OK).
- **공유 프리미티브 GB 완료**: `Input.tsx:49`, `surfaces.tsx`(카드/버튼 radius0+2px+pixelShadow), `feedback.tsx:167-225`(orb/sheet/modal/toast 전부 GB, 사각 toastDot) — 화면들만 따라오면 됨.
- **폰트 매핑 정상(오탐 주의)**: `fontFamilies.sans`는 픽셀 페이스(NeoDunggeunmo)로 resolve → "sans" 사용은 시스템폰트 잔재 **아님**(`typography.ts:57`). body는 `readable`(Pretendard). `Text.tsx:22-28` variant→픽셀 매핑 정상.
- **점진 공개·상태 처리 양호**: 캡처(첫 진입 단일 CTA + 더보기, `:1091-1105`)·세컨비(quick-action/소스칩/drawer 전부 탭 뒤)·프로필(구독카드 우세 위계)·온보딩(스텝당 1 primary)·loading/error/empty/limit 상태 대부분 정의됨.

---

### 권장 커밋 순서
1. **CC-1**(GB 토큰 교체, 5화면 1커밋) — 최대 가시 효과 + P1-4 깨진 카드 동시 해결.
2. **P1-1**(홈 시트 가림) — 유일한 진짜 깨진 상호작용.
3. **P1-2 / P1-3**(세컨비 그래픽 / 설정 벽).
4. **CC-2**(`surfaces.tsx:479` 44→48 + 칩 hitSlop).
5. **CC-3** + P2 일괄.