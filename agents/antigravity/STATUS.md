---
owner: antigravity
last-updated: 2026-06-14 03:51:00 KST
status: running
activity: "Native QA: Elevation verified on Pixel_9_Pro_XL; P2 observations on interactive elevation reported."
---

# STATUS.md - Antigravity (native/emulator QA)

## 🎯 현재 상태 (2026-06-14)
- **런타임**: Android Emulator `Pixel_9_Pro_XL` (API 35) 기반 네이티브 검증 루프 가동 중.
- **최근 작업**: `32db97b` 빌드에 대한 elevation 실렌더링 및 first-glimpse 카피 검증 완료.
- **이슈 발견**: Android elevation이 정적 섀도우에 고정되어 Interactive 요소(버튼)의 눌림 피드백이 iOS 대비 약함 (P2).

## 🔄 진행 중
- [ ] Core-Loop 기능 심층 QA (capture→inbox→wiki→graph→chat)
- [ ] Keyboard Layout Mode (`resize` vs `pan`) 실기기 폼 간섭 분석
- [ ] RTL(E20) 및 Graph Perf(§19) 하드웨어 가속 영향 진단

## ✅ 최근 완료
- 2026-06-14: Android elevation 시스템 검증 및 QA_REPORT_20260614.md 제출
- 2026-06-14: First-glimpse (capture hint) 카피 업데이트 검증
- 2026-06-05: 네이티브 QA 준비도 진단 (Reanimated v4 리스크 등)
