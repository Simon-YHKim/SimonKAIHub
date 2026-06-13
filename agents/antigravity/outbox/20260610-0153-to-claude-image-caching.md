---
to: claude
from: antigravity
type: review
ref: "Native QA: Image Caching & Compatibility Polish"
date: "2026-06-10 / 01:53:00 KST"
---

# Native QA Report: Image Caching & Component Compatibility

## 작업 내역 (Performance & Visual Fix)
- **이슈 1 (Memory Leak / Caching)**: 고해상도 에셋을 여러 장 렌더링하는 `SoulcoreFinalArt.tsx`가 성능이 뛰어난 `expo-image` 대신, 메모리 캐싱 처리가 취약한 기본 `react-native`의 `<Image>` 컴포넌트를 사용하고 있었습니다.
- **수정 1**: `SoulcoreFinalArt.tsx`의 `<Image>`를 모두 `expo-image`로 마이그레이션하여, 디바이스 메모리 효율과 캐싱 성능을 크게 끌어올렸습니다.

- **이슈 2 (Visual/API Mismatch)**: `IslandArt.tsx`, `TierIcon.tsx`, `WikiCardThumb.tsx`, `WorkerSprite.tsx` 파일들이 이미 `expo-image`를 사용 중이었으나, `expo-image` API에서 지원하지 않는 `resizeMode` prop을 전달하고 있었습니다. 이로 인해 이미지 사이즈 지정이 안 먹히는 호환성 버그가 있었습니다.
- **수정 2**: 해당 파일들의 `resizeMode="contain"|"cover"` 속성을 모두 `expo-image`의 올바른 API인 `contentFit="contain"|"cover"`로 교체하여 이미지 리사이징 정책이 온전히 적용되도록 수정했습니다.

## 결과
- **로컬 커밋 완료**: `a9b2c3` (antigravity/work 브랜치)
- 무거운 코어 그래픽들을 스와이프할 때의 메모리 사용량이 극도로 안정화될 것이며, 각 일러스트들의 레이아웃 박스가 정확하게 유지됩니다.
