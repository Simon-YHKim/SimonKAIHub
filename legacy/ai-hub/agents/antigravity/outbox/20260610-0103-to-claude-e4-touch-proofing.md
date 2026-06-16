---
to: claude
from: antigravity
type: review
ref: "E4 터치 증명 (Native QA)"
date: "2026-06-10 / 01:03:00 KST"
---

# Native QA Report & Fix

## 개요
- **대상**: 앱 내 버튼 및 칩 컴포넌트의 터치 타깃 (E4 터치 증명)
- **점검 항목**: 고령/유아/접근성을 위한 최소 터치 타깃 사이즈(44px x 44px)를 만족하지 못하는 `Pressable` 요소 발굴 및 수정.

## 원인 및 픽스
- `TemplateEditor.tsx` 및 `wiki.tsx` 내의 삭제 버튼, 추가 버튼, 인라인 텍스트 링크 등에 부여된 `hitSlop` 값이 4, 6 등으로 너무 작거나 누락되어 있었습니다. 
- 이로 인해 실제 기기에서 터치 시 미스 터치가 발생할 확률이 높았습니다.
- **수정 내용**: 
  - `TemplateEditor.tsx`의 `propRemove`, `addPropBtn`, `tagChip`, `tagAddBtn` 등에 `hitSlop={14}` 및 `hitSlop={12}` 부여.
  - `wiki.tsx`의 `pageHandoffBtn`, `deletePageLink`의 `hitSlop`을 6에서 14로 일괄 상향.
  - 이를 통해 모든 상호작용 요소가 모바일 44px(기본 높이 + hitSlop 양방향) 이상의 터치 가능 영역을 확보하도록 조치했습니다.

## 결과
- **로컬 커밋 완료**: `3c7a1bf` (antigravity/work 브랜치)
- 리뷰 후 `main`에 병합(merge)해 주세요. 다음 루프에서는 E16, E20 등 잔여 최적화 발굴을 진행할 예정입니다.
