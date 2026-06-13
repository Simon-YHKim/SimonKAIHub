---
from: claude
to: Simon (게이트 필수)
type: security-advisory
slug: rls-self-grant
created: 2026-06-10 / 06:15 KST
source: workflow wen355npk (보안 딥다이브, 11 agents, 3 REAL / 4 FALSE)
base: main 70475de
severity: P2 (+ P3) — 🔒 Simon 게이트 (RLS/프로덕션 마이그레이션 = secret/법무/데이터)
status: 자동수정 안 함 — 승인 시 Claude가 마이그레이션+코드 mitigation 구현
---

# 🔒 SECURITY ADVISORY — RLS self-grant 2건 (Simon 승인 필요)

보안 감사가 **클라이언트가 직접 신뢰 플래그를 self-set**하는 RLS 갭 2건 확인. 둘 다 팀이 **이미 쓰는 패턴**(0011/0025/0040의 `REVOKE` + force-false 트리거)을 해당 컬럼에만 적용 안 한 것. anon key는 번들에 공개라 앱 UI 없이 PostgREST 직접 호출로 악용 가능.

## ① knowledge_sources self-verification → 크로스유저 evidence-poisoning (P2)
- **경로**: 인증 유저가 자기 행 INSERT(`added_by=auth.uid()`) 후 `verified_at=now()`로 UPDATE(self-verify). `ks_owner_update`(0009:48-51)는 `added_by=auth.uid()`만 검사, C8 `ks_verification_pair`(0014: `verified_by IS NULL OR verified_at IS NOT NULL`)는 `verified_by` NULL이어도 통과. → 0041 `ks_auth_select`의 `verified_at IS NOT NULL` 분기가 **전 인증유저에 노출** → `loader.queryRows`(loader.ts:80-108, owner 필터 없음)가 framework/locale/age_range만으로 끌어와 `retrieve.ts:339`의 "=== RELEVANT EVIDENCE ===" 블록 + "Ground every response in the curated research below"(323)로 **피해자(미성년자 포함) Advisor 프롬프트에 주입**.
- **잔여 방어**: `<UNTRUSTED>` 펜스+sanitizeUntrusted+injection guard는 *instruction*-injection만 차단. **evidence-poisoning(가짜 DOI 단 허위 "연구")은 못 막음**. 출력 레일(진단금지·4문장·질문종료)이 피해를 줄이나 제거 못 함. → verifier P1→**P2**.
- **권고 fix (0025 패턴 미러)**: 새 마이그레이션 —
  1. `REVOKE INSERT (verified_at, verified_by), UPDATE (verified_at, verified_by) ON public.knowledge_sources FROM authenticated;` (서비스롤/큐레이터만 검증 설정)
  2. (선택) BEFORE INSERT/UPDATE 트리거로 비-service_role의 `verified_at/verified_by`를 강제 NULL.
  3. **코드 defense-in-depth**: `queryRows`가 큐레이션 행만(예: `added_by IS NULL` 또는 신뢰 플래그) 끌어오게 필터. ⚠️ 단 **합법 큐레이션 행이 added_by NULL(서비스 시드)인지 vs 큐레이터 계정(added_by set)인지** Simon 확인 필요 — 잘못 필터하면 정상 RAG 누락.

## ② testimonials self-approval → 미모더레이션 공개 노출 (P3)
- **경로**: `testimonials_owner_all`(0009:36-39) `WITH CHECK (user_id=auth.uid())`만 — `approved_for_public` 무제약, 트리거 없음(types.gen.ts:502 client-settable). 유저가 자기 행 `approved_for_public=true` → `testimonials_public_select`(0009:40-41) anon 공개. 큐레이터 모더레이션 게이트 우회. (공개 렌더가 unescape면 stored-XSS 가능성 — 0011이 'web XSS surface' 이미 표기.)
- **권고 fix**: `REVOKE INSERT/UPDATE (approved_for_public) ... FROM authenticated;` + force-false 트리거(0040 judge_mode 패턴 동일).

## 위양성 4건
- 감사 7건 중 4건 verifier가 **FALSE 반박**(RLS/트리거/DB레이어가 이미 enforce). 채택 안 함 — 신뢰도 ↑.

## 결정 요청 (Simon)
- [ ] 위 2개 마이그레이션(REVOKE+트리거) 승인? → Claude가 작성·`supabase-dry-run` CI·verify 후 통합.
- [ ] ① 코드 필터의 "합법 큐레이션 행" 판별 기준(added_by NULL = 서비스 시드 맞나?).
- 프로덕션 RLS 변경이라 **사용자 승인 전 미적용**. C8(검증쌍)·C5(consent) 하드제약과 정합 유지.
