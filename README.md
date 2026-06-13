# SimonKAIHub

> **AI 제품/기능을 끝까지 빌드하는 오케스트레이션 플러그인** — LLM 앱·에이전트·RAG·프롬프트·평가·AI 인프라·AI 안전을, 평가/안전 게이트를 건너뛰지 않고 단계별로.

SimonK 플러그인 스위트의 AI 도메인 워크스테이션. 사용자가 만드는 AI 제품/기능을 돕는다(이 플러그인 자체의 내부 동작이 아님).

## 진입점

```
/skaihub
```

의도를 러프하게 진단(쉬운말·티어) → 적절한 AI 파이프라인으로 라우팅 → 산출물마다 반복 디벨롭 → **평가·안전 게이트 + persona-validate**로 마무리.

## 설치

```
/plugin marketplace add Simon-YHKim/SimonKAIHub
/plugin install simonk-aihub@simonk-aihub
```

**권장 동반**: `SimonKCore`(agent-delegate·model-router·persona-validate 등). 실제 앱 빌드·배포 연계는 `SimonKStack`.

## 수록 스킬

**오케스트레이터**
- `skaihub` — AI 빌드 진입점·라우터·게이트

**AI 빌드 (net-new)**
| 스킬 | 하는 일 |
|---|---|
| `prompt-engineering` | 프롬프트 설계(패턴·structured output·인젝션 방어·eval 루프) + 템플릿·eval 러너 |
| `rag-builder` | RAG 파이프라인(청킹·임베딩·벡터스토어·하이브리드·리랭크·인용강제·평가) + pgvector 스키마·eval 스크립트 |
| `agent-builder` | tool-use 에이전트(도구 스키마·실행 루프·가드레일·멀티에이전트) + 루프/가드레일 템플릿 |
| `llm-eval` | 평가 하네스(골든·엣지·적대셋·LLM-judge·회귀 게이트·레드팀) + CI 게이트 스크립트 |
| `ai-model-selector` | 제품용 모델/프로바이더 결정(작업적합·비용·레이턴시·프라이버시·라우팅·폴백) |
| `ai-safety-eval` | AI 안전(입출력 가드레일·모더레이션·PII·탈옥 레드팀·편향·환각 완화) |

**AI 인프라 (자급자족 번들)**
- `model-router` · `gcloud-helper`(Vertex/Gemini 인증)

## 원칙 (게이트)

- **평가 우선**: 프롬프트/RAG/에이전트 변경마다 `llm-eval` 회귀 확인. 평가셋 없이 프로덕션 금지.
- **안전 게이트**: 출시 전 `ai-safety-eval`(가드레일·레드팀·PII) 필수.
- **검증 게이트**: 완료 직전 `persona-validate`(Core)로 AI 전문가 + 대상 사용자 패널 점검, 치명 리스크 0.
- 시크릿(API 키) env, 비용·레이턴시 상한, 모델 호출 로깅, 환각엔 근거·인용·휴먼인루프.
- 최신 모델만 참조: Claude Opus 4.8 / Sonnet 4.6 / Haiku 4.5 / Fable 5, Gemini 2.x.

## 라이선스 / 출처

MIT. 일부 인프라 스킬은 Simon 의 기존 SimonK 스택에서 가져왔고 gstack(garrytan, MIT) 출신이 섞일 수 있으며 출처는 각 SKILL.md·NOTICE 에 유지. © Simon Kim (Simon-YHKim).
