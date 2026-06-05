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

## 다음 액션
- [ ] 사용자에게 첫 작업 항목 받기

## 산출물 링크
- 코드: (PR/브랜치 링크)
- 디자인/에셋: (asset/* 브랜치)
- QA 리포트: (antigravity outbox)
