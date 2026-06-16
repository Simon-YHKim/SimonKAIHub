# /goal 사이클 1 — 이월 펀치리스트 (2026-06-10 13:45 KST)

5렌즈 발굴 워크플로(wf_53ed105f, 에이전트 31, 확정 11/기각 15) 중 이번 사이클에서 **적용하지 않고 이월**한 항목. 다음 사이클 또는 Simon 결정 대기.

## P3 — 다음 사이클 후보 (비게이트)

1. **wiki upsert stale source_id race** (`src/lib/wiki/queries.ts:110`) — 소스 삭제와 phase2 생성이 겹치면 FK 제약으로 불투명 에러. 발생확률 낮음(검증자 인정). 수정 방향: caller에서 제약 위반 catch 후 우아한 강등, 또는 RPC 원자화.
2. **`_body_fallback` 승격 메커니즘 부재** (`src/lib/wiki/capture.ts`) — Storage 업로드 실패 시 본문이 frontmatter에 영구 체류. 수정 방향: 다음 세션 시작 시 pending 소스 재업로드 시도(클라이언트) 또는 Edge Function 배치.
3. **import.tsx도 storagePending 미노출** — capture.tsx에는 이번에 노출(#302), import 표면은 미적용.
4. **isoWeek(UTC) vs 일자 컨벤션(KST) 불일치** (`src/lib/journal/insights.ts`) — daySpan은 #302에서 KST로 정렬했으나 byWeek 주간 버킷은 여전히 UTC ISO week. 시각적 영향 작음(주 단위), 고치면 주간 차트 경계가 KST로 정렬됨.
5. **`.catch(() => undefined)` 무음 패턴 잔존** — `QuantIntroModal.markSeen`, `lib/…/empty-card.ts` 등. onboarding만 #302에서 warn 트레이스 추가. 일괄 정리 후보.

## Simon 결정 대기 (기존 보류 유지)

6. **CrisisRouter.tsx:54 / ConsentNotice.tsx:140 hex 잔존** — Codex anti-slop 사이클의 기존 보류(consent/safety 민감 표면, 자율변경 금지) 유지. semantic 토큰화는 1줄 작업이나 표면 민감성 때문에 Simon 승인 후 진행 권장.

## 게이트 진행 중

- **PR #301** (C9 후속 422 위기 폴백) — 안전임상 게이트, ORDERS_REMOTE OPEN에 결정요청 게시됨. CI green, 승인만 대기.

## 적대검증 기각 15건 (참고)

edge 렌즈 8건 전부 기각(컨벤션 오해·이미 가드됨), data 3건, ux 2건, structure 1건, 기타. 상세는 워크플로 출력 보존본 참조.
