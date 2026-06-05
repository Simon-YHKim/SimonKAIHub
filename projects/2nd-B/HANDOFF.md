---
project: 2nd-B
repo: https://github.com/Simon-YHKim/2nd-B
default-branch: main
workflow: branch-per-task + PR (asset/* = 디자인·에셋, claude/* = 코딩, qa/* = 검수)
owner: claude
updated: 2026-06-05 15:33:32 KST
phase: build
---

# 2nd-B — HANDOFF (always-latest)

> 메인 앱 프로젝트. 실제 코드/에셋은 **github.com/Simon-YHKim/2nd-B** 에 있고(브랜치-per-작업 + PR), 이 허브는 **코디네이션 채널**이다. 메시지는 브랜치·PR·커밋·스크린샷을 **링크로** 참조한다(코드 자체를 허브에 복사하지 않음).

## 개요
- (Claude가 사용자 확인 후 1~2줄 채움)

## 역할 ↔ 브랜치 매핑
- **Claude(코딩)** → `claude/*` 브랜치, PR로 main 병합.
- **Codex(이미지·UI/UX)** → `asset/*` 브랜치(디자인·에셋), UI 스펙은 허브 메시지로 전달.
- **Antigravity(네이티브 검수)** → 빌드/브랜치 QA, 리포트는 허브 메시지로. 코드 수정 필요 시 Claude로 request.

## 현재 상태
- 설계(codex):
- 구현(claude):
- QA(antigravity):

## 라이브 검증 사이클
- 대단위 사이클 종료 + 사용자 라이브 확인 필요 시: push → PR로 main 머지 → 라이브 화면 제공 (PROTOCOL §8).
- **라이브 화면 수단 (확정)**:
  - 기본 = **Android Studio/Gradle 로컬 빌드 + 에뮬레이터(AVD Pixel_9_Pro_XL) 실행 + 스크린샷** (빌드·실행·캡처는 Antigravity 위임 가능, Claude 전달).
  - 향후 = 계정/계정별 데이터 필요 작업 → **자동배포 URL**(GitHub Actions + Cloudflare/Vercel) 구축 후 제공.
- 빌드 환경 준비됨: Android SDK + Studio + JDK17 + AVD. 단 **2nd-B 로컬 클론 위치 미확인**(빌드하려면 필요).

## 다음 액션
- [ ] 2nd-B 로컬 클론 위치 확인/지정 (빌드용)
- [ ] 첫 대단위 작업 사이클에서 라이브 빌드 1회 리허설
- [ ] (향후) 계정-데이터 작업 시 자동배포 파이프라인 구축

## 산출물 링크
- 코드: (PR/브랜치 링크)
- 디자인/에셋: (asset/* 브랜치)
- QA 리포트: (antigravity outbox)
