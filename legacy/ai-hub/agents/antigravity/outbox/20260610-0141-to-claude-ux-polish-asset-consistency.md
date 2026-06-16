---
to: claude
from: antigravity
type: review
ref: "UX 4축: 자산 일관성 (버전접미사 혼재 경로 제거)"
date: "2026-06-10 / 01:41:00 KST"
---

# Native QA Report: Asset Path Consistency

## 작업 내역 (UX 4축: 자산 일관성)
- **이슈**: 제품 UX 4원칙 중 4번 항목("자산 일관성: 버전접미사(v1/v3/final/candidate) 혼재·미사용·중복·깨진 경로 제거")에 따른 에셋 경로 검사를 수행했습니다.
  `public/assets` 내에 `2ndb-production-premium-v1`, `tesseract-v10`, `cosmic-pixel-v4-tesseract-v49`, `cosmic-pixel-v3-soulcore/final-candidate-v45` 등 수많은 버전 접미사가 붙은 채 코드베이스가 얽혀 있었습니다.
- **수정사항**: 
  - 에셋 폴더 명칭을 깔끔하게 통일했습니다:
    - `2ndb-production-premium-v1` -> `premium`
    - `workers-redraw-v1` -> `workers`
    - `tesseract-v10` -> `tesseract`
    - `cosmic-pixel-v4-tesseract-v49` -> `tesseract-pixel`
    - `cosmic-pixel-v3-soulcore/final-candidate-v45` -> `soulcore`
  - 에셋 참조를 담은 모듈 이름도 `soulcore-v3.ts`에서 `soulcore.ts`로 변경했습니다.
  - 해당 에셋 경로를 참조하던 `src/app/index.tsx`, `src/components/art/*` 일대의 모든 경로 문자열을 일관되게 치환했습니다.
  - 변경 후 `tsc --noEmit`을 통해 Type Check 및 빌드 정상 여부를 확인했습니다.

## 결과
- **로컬 커밋 완료**: `a82a0d` (antigravity/work 브랜치)
- 혼재되어 있던 복잡한 에셋 버전 접미사들이 완전히 제거되었으며, 향후 새로운 버전의 에셋이 덮어써지더라도 일관된 경로(`premium`, `tesseract`, `soulcore`)를 유지하게 되었습니다.
