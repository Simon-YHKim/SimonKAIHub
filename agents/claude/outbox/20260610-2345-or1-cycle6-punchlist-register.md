---
id: 20260610-2345-or1-cycle6-punchlist-register
from: claude (O-R1 루프)
to: claude-loop (차기 사이클 입력)
type: findings_register
project: 2nd-B
created: 2026-06-10 23:45 KST
---

# O-R1 사이클 6+ 입력 레지스터 — 여정 discovery + 적대리뷰 비차단 잔여 + AG 네이티브 QA

> 출처: 사이클 5 워크플로(wf_30b1c51c, 에이전트 4) discovery 패스 + 3렌즈 비차단 발견 + AG 회신(20260610-2149).
> 사이클 5에서 닫힌 것: E2E-3·E2E-4(P1, PR #321), E2E-5·E2E-6(P2, PR #321), IntroGate 콜드스타트 P1(동일 PR), J2(=IntroGate 건과 동일).
> **[2026-06-11 / 00:25 KST 갱신] 사이클 6에서 닫힌 것: J1(P1, PR #322) + 적대리뷰 신규 P2 2건(a11y 그래프 약속 힌트·record 상세 see-in-graph 무동작, 동일 PR).**
> **사이클 6 적대리뷰(wf_4ced8621) 신규 이월 P3**: ① 리본 records-only 상태의 탭 목적지(/core-brain)를 /records로 분기 검토 ② tagless journal의 domainForTags 기본값 knowledge→records(내러티브 코어 빈 목록 방지) ③ records 행 "오늘의 조각·오늘의 조각" 제목 중복(evidence.ts 폴백) ④ Landing 데이터 fetch가 [userId] 키만 — focus refetch 없음(back-pop 캐시 stale, 기존).

## 여정 단위 (post-signup, discovery 패스)

### J1 (P1) 첫 저장 조각이 약속된 그래프에 안 보임
- onboarding이 "저장한 뒤 그래프에서 다시 볼 수 있어요"(onboarding.tsx:54-57) 약속 → /capture 기본 journal 모드는 `records`에 저장 → 그래프 노드는 `sources`만(index.tsx:289-318, 주석 자인 index.tsx:173-177). 첫 저장 후 그래프 신규 노드 0 + hasAnyPiece가 정직 리본을 끄고 랜덤 "We noticed something" 라인으로 교체(index.tsx:115-137) + 빈 dataNodes에 "지식 코어에 조각들이 모여 있어요" 스포트라이트(index.tsx:356-369).
- 방향: records를 tier-4 노드 또는 Records 배지로 표면화, dataNodes>0 전까지 정직 리본 유지. **첫 가치 경험(아하 모먼트) 직결 — 차기 사이클 1순위.**

### J3 (P2) 기존 이메일 재가입 막다른길
- 등록된 이메일로 signUp → enumeration-safe 가짜 성공+세션 없음(auth.ts:101-118) → 새 비번으로 signInWithPassword 실패 → generic signUpFailed 토스트 루프. 계정 있는 걸 잊은 사용자에게 회복 경로 없음.
- 방향: no-session signUp 후 invalid-credentials면 "이미 계정이 있나요? 로그인" 토스트+CTA (enumeration-safe 문구 유지 주의).

### J4 (P2) 첫 가치 전 게이트 스택 과다
- intro 탭 → 3-step onboarding(1·2단계 정보가치 낮음) → capture. 이미 email+pw+DOB+동의 4체크 입력 후. `entry:"firstRun"` 파라미터는 capture.tsx에서 미사용.
- 방향: onboarding 1-step 압축 또는 capture 헤더 인라인화 + firstRun "한 문장이면 충분해요" 프레이밍.

### J5 (P3) onboarding 백애로우 루프
- 전역 BackArrow가 /onboarding에 노출, "/" push → index가 즉시 되돌림 = step 0 리셋만 하는 컨트롤. HIDDEN_PATHS에 "/onboarding" 추가.

## 적대리뷰 비차단 잔여 (P3)

- R1: sign-up `loading` 플립이 제출 중 폼을 InlineLoader로 교체(최악 probe 8s) — 시각 플래시, correctness 무관.
- R2: refresh() 타임아웃 폴백이 신규 uid에 hasProfile:false — flake 시 1회 바운스(자인 주석 있음).
- R3: canSubmit이 oauthSubmitting 미반영(diff 외 기존) — OAuth 진행 중 이메일 제출 가능.
- R4: sign-in.tsx `logo` 미사용 스타일(기존), sign-up↔sign-in 교차링크 위치/처리 비대칭(Principle 6) — sign-up쪽 "Sign in" 링크도 위로 올릴지 검토.
- R5: 첫 화면 인사 카피 distinctiveness("어서 오세요"가 가게 인사로 읽힐 수 있음) — Grok 회신(20260610-2310 요청) 대기 후 판단.

## AG 네이티브 QA 잔여 (20260610-2149, AG quota-out으로 코드리뷰만)

- ~~N1 (P2): interview periodCard minHeight~~ ✅ **PR #323**(Codex 구현·Claude 통합, 2026-06-11 00:33)
- ~~N2 (P2): interview footer Android kbHeight 보정~~ ✅ **PR #323**
- ~~N3 (P2): QuantPager accessibilityHint~~ ✅ **PR #323** (+progressbar accessibilityValue)
- **멀티모달 통합 사이클 입력 추가**: Grok cycle9 FYI(20260611-001941) — OCR/사진 캡처에 ① 로컬처리·no-training 고지 카피 ② 추출 텍스트 사용자 검토·승인 단계(커밋 전) ③ 소유감 언어("your extracted text") 권고. gemini-proxy 비용 게이트 검토와 함께 처리.
- N4 (P3): Android shadow* 무시 → elevation 분기 (sign-up·complete-profile·index 다수).
- N5 (P3): interview BackHandler 데이터 소실 확인 대화 부재.
- N6 (P3): QuantPager 진행률 바 screen-reader 값 없음.
- E4·E16·E20·§19: 에뮬 실측 필요 — AG quota 복구 또는 Claude 직접 에뮬 세션.

[2026-06-10 / 23:45:00 KST — claude O-R1 사이클 5 마감 산출]
