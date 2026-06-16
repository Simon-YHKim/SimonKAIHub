---
id: 20260606-150500-claude-fyi-multimodal-pair-rule
from: claude
to: all
type: fyi
ref: ""
project: 2nd-B
priority: high
status: open
created: 2026-06-06 15:05:00 KST
---

# 신규 규칙 — 멀티모달 페어 (Codex ⇄ Antigravity) PROTOCOL §19

## 무엇
Simon 결정(2026-06-06): Codex·Antigravity는 멀티모달 성능이 뛰어나니, **멀티모달 산출물은 둘이 병렬 생성 → 서로 평가 → 피드백 → 반복 개선**한다.

## 적용 대상 (멀티모달만)
이미지/에셋 생성·편집, 아이콘·일러스트·스프라이트, 마스코트·히어로 아트, UI 렌더링 충실도, 디자인-투-디바이스, 시각 QA(스크린샷 비교), 애니메이션/모션 비주얼.

## 루프 (PROTOCOL §19 / ROUTING §4)
1. **병렬 생성**: 같은 과제를 Codex·AG가 각자 독립 산출(자기 outbox + HTML preview).
2. **상호 평가**: 각자 상대 산출물을 읽고 `type: review`(ref: 상대 deliverable id)를 **자기 outbox**에 작성 — 점수 + 강점 + 구체 개선점.
3. **반영**: 받은 평가로 개선(다음 라운드).
4. **반복**: 둘 다 approve 또는 최대 2~3라운드. 수렴 못 하면 Claude 판정.
5. **머지**: Claude가 수렴본 수거·머지(온라인 git은 Claude 단독).

## 강점 분담
- **Codex**: 디자인·생성·심미·레이아웃 평가.
- **Antigravity**: 네이티브 렌더링·성능(프레임/OOM)·디바이스 충실도 평가.

## 적용
- 다음 사이클부터 멀티모달 작업은 이 페어 루프로. 비-멀티모달(로직·텍스트·빌드)은 기존 lane 그대로.
- 현재 진행 중인 멀티모달 후보: AG의 D-06 스크린샷 매트릭스 / Codex 에셋·스프라이트류 → 서로 교차 평가 대상.
- 갱신본: PROTOCOL.md §19, ROUTING.md §4, prompts/codex-activate.md §6-1, prompts/antigravity-activate.md §5-1. 다음 사이클 시작 시 읽어 반영하라.
