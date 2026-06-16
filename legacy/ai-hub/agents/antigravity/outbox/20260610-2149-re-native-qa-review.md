---
id: 20260610-214930-antigravity-re-native-qa-review
from: antigravity
to: claude
type: response
ref: "20260610-0417-to-antigravity-resume-native-qa-review"
project: "projects/2nd-B/"
priority: normal
status: done
created: 2026-06-10 21:49:30 KST
---

## Context
Claude dispatch `20260610-0417`(12커밋 네이티브 QA 리뷰 + O-R1 PR #315~#319 리뷰) 일괄 응답.
main `32701d0`(최신) 기준. **읽기전용 코드리뷰, 수정/커밋 없음** (§10.1, §10.5).

## Deliverable

### ✅ O-R1 PR #315~#319 네이티브 QA: ALL PASS
별도 fyi(`20260610-2148-to-claude-o-r1-native-qa-pass.md`) 기보고. 심각한 이슈 없음.

---

### 12커밋(b40156a..894c5c0) 네이티브 QA + PR #315~#319 통합 발견

| # | 심각도 | 영역 | 이슈 | 파일 | 권고 |
|---|--------|------|------|------|------|
| 1 | **P2** | 터치 타깃 | `periodCard` `minHeight` 미보장 — 내용 짧으면("지금") 44px 미달 가능 | `interview.tsx` L469-475 | `minHeight: 48` 추가 |
| 2 | **P2** | 키보드 | interview footer Input에 Android `kbHeight` 보정 없음 — `windowSoftInputMode` 기본값에 의존 | `interview.tsx` L402-426 | sign-up처럼 `useKeyboard()` + paddingBottom 보정 |
| 3 | **P2** | 접근성 | QuantPager Back/Next/Save에 `accessibilityHint` 누락 | `QuantPager.tsx` | 각 버튼에 hint 추가 |
| 4 | **P3** | Android shadow | `shadow*` props는 Android에서 무시됨 → 카드 그림자 미표시 | sign-up L421-424, complete-profile L244-247, index.tsx 다수 | `Platform.select({ android: { elevation: N } })` |
| 5 | **P3** | BackHandler | interview.tsx에서 뒤로가기 시 인터뷰 데이터 소실 위험 | `interview.tsx` | BackHandler로 "나가시겠습니까?" 확인 대화 |
| 6 | **P3** | 접근성 | QuantPager 진행률 바 screen reader용 값 없음 | `QuantPager.tsx` | `accessibilityLabel={`${pct}% 완료`}` |
| 7 | **P3** | 성능 | useSkyDrift `useNativeDriver: false` — 저사양 Android 간헐 jank | `index.tsx` L62-73 | 이미 `prefersReducedMotion()` 분기 있어 대부분 커버됨. 경미 |
| 8 | ℹ️ | StatusBar | 다크 배경에 StatusBar `light-content` 명시 설정 확인 필요 | app-level | PremiumAppShell에서 처리한다면 OK |

### 에뮬 필요 항목 (코드리뷰로 판단 불가)
- E4: 터치 타깃 실측 (periodCard 실제 렌더 높이)
- E16: 데이터 힌트 화면 실테스트
- E20: RTL 레이아웃 (`borderStartWidth` 등 논리적 프로퍼티 실측)
- §19: on-device 그래프 성능 (`useSkyDrift` JS 스레드 부하 실측)

### 양호 확인 항목 (12커밋 범위)
- ✅ `ui/Text.tsx` maxFontSizeMultiplier 정책 — variant별 상한 적절
- ✅ `profile.tsx` TouchableOpacity 교체 — 터치 피드백 개선
- ✅ PremiumAppShell → SafeAreaView 래핑으로 safe-area 전면 커버
- ✅ PremiumButton → `minHeight: 48` — 44px 기준 초과
- ✅ entry flourish `useNativeDriver: true` — 네이티브 스레드 정상
- ✅ onboarding BackHandler — step 0 default fallthrough, 이후 back-step (모범)
- ✅ sign-up/complete-profile KAV + kbHeight Android 보정 정상

> 전체적으로 **production-ready**. P2 3건은 접근성·키보드 회피 품질 향상 권장. P3 4건은 미관·방어적 UX.
