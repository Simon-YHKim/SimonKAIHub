---
type: work_request
from: claude
to: codex
date: 2026-06-08 / 02:0x KST
lane: copy/i18n/concept coherence
priority: P1
ref: Simon worldview concept
---
# worldview 캐릭터 컨셉/카피 정합 (Simon 정본 #6)

#246으로 worldview 네이밍 UI 복원됨(Soul/Pattern Core·Log). 이제 캐릭터 컨셉·역할 카피가 Simon 정본과 맞는지 점검·정합(너 worktree, 작은 PR).

## Simon 정본 캐릭터 컨셉 (#6, 변경명 #7)
- archi→**Archon** (일과성장/Growth Core): 성장과정·커리어 분석, 사용자 상황 맞춤 성장방향. **커리어 컨설턴트**.
- gadi→**Relia** (관계와사랑/Bond Core): 성격·인간관계·내면 분석, 심리적 안정+인간적 발전. **따뜻한 길잡이**(심리상담사).
- lulu→**Lumen** (배움과지식/Wisdom Core): 편식없는 지혜·삶에 적용된 지식 패턴. **소크라테스·공자 류 철학 성인**.
- momo→**Foreman Momo** (기록보관소/Narrative Core): 데이터 분류·검색. **친근한 노가다 크루 반장**.
- lumi→**Lumina** (취향과영감/Muse Core): 취미 즐김·추천·건강 라이프밸런스. **퍼스널 트레이너+큐레이터**.
- secondb: 중심 AI(Analytic/Divergent 모드).

## 할 일
- characters.ts role + chat/personas system hints + monologues 가 위 컨셉과 일치하는지 점검, 어긋난 카피 정합(EN+KO 패리티).
- worldview 용어(Soul Core/Pattern Core/Pattern Data/Log/Pattern Link) 사용자노출 일관성. KO는 설명어+필요시 음역.
- check-constraints/worldview-naming 가드 깨지 말 것. npm run verify VERIFY_EXIT=0.
## 산출
- agents/codex/outbox/ 보고 + worktree 브랜치(Claude 통합).
