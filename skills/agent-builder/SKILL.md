---
name: agent-builder
description: "사용자가 만드는 AI 제품/기능에 에이전트형(tool use / function calling) 시스템을 설계·구현할 때 쓴다. 트리거: \"AI 에이전트 만들어\", \"tool use\", \"function calling\", \"함수 호출 루프\", \"멀티에이전트\", \"agent loop\", \"tool 정의\", \"에이전트 설계\", /agent-builder. 산출물: (1) 도구/함수 스키마 정의, (2) 계획·실행 루프 설계, (3) 메모리/상태 관리, (4) 멀티에이전트 토폴로지(팬아웃·파이프라인·수퍼바이저), (5) 가드레일·종료조건·루프방지, (6) 관측성·비용상한. Claude(@anthropic-ai/sdk tool_use) 또는 Gemini(@google/genai function calling) 둘 다 커버. 이건 사용자 앱에 들어갈 에이전트를 만드는 스킬이지, Claude Code 내부 subagent 위임이 아니다 — 그건 agent-delegate[Core]."
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
version: 1.0.0
author: simon-stack
---

# agent-builder — 에이전트형 AI 시스템 구축

> 사용자가 **자기 제품/기능에 넣을** tool-use 에이전트를 설계·구현하도록 돕는다.
> Claude Code 내부에서 작업을 subagent 에 위임하는 메타 작업(`agent-delegate`[Core])과 혼동하지 말 것 — 여기는 "출하될 코드" 레이어다.

## 0. 먼저 거른다 — 정말 에이전트가 필요한가

에이전트(자율 도구 호출 루프)는 비싸고 불안정하다. 아래 한 줄로 판정한다:

> **"입력 → 한 번의 LLM 호출 → 출력으로 끝나는가?"**

| 답 | 권장 |
|---|---|
| 응, 단발성 변환/생성/분류 | 에이전트 X. 단순 prompt 호출 또는 structured output 한 방 |
| 단계가 고정돼 있다 (항상 A→B→C) | 에이전트 X. 코드로 짠 **워크플로**(고정 체인)가 더 싸고 안정적 |
| 입력에 따라 도구·단계 수가 달라진다 | 에이전트 O. 아래 진행 |

고정 워크플로로 충분하면 거기서 멈추고 사용자에게 알린다. 에이전트는 "다음에 뭘 할지 모델이 정해야 할 때"만 정당화된다.

## 1. 진단 (AskUserQuestion 으로 확정)

설계 전 아래를 못 박는다. 모르면 `AskUserQuestion` 으로 묻는다.

| 항목 | 질문 |
|---|---|
| 모델 | Claude(Opus 4.8 / Sonnet 4.6 / Haiku 4.5) vs Gemini 2.x — 이미 정해졌나? |
| 도구 | 에이전트가 호출할 도구 후보는? (DB 조회, 검색, 계산, 외부 API, 파일 IO) |
| 부작용 | 쓰기/결제/메일 등 **되돌릴 수 없는 도구**가 있나? (있으면 승인 게이트 필수) |
| 종료 | "성공"의 정의는? (최종 답 도출 / 특정 도구 결과 / 사용자 승인) |
| 예산 | 1 요청당 최대 LLM 호출 수·토큰·비용 상한은? |
| 멀티 | 단일 에이전트로 되나, 아니면 역할 분리가 필요한가? |

## 2. 도구/함수 스키마 정의

에이전트의 품질 = 도구 스키마 품질. 핵심 규칙:

1. **이름은 동사+목적어** — `get_weather`, `search_orders`, `create_invoice`. 모호 금지(`do`, `process`).
2. **description 이 진짜 사양** — 모델은 description 만 보고 호출한다. "언제 쓰는지 / 언제 쓰면 안 되는지"를 명시.
3. **파라미터는 JSON Schema, enum 으로 좁혀라** — 자유 문자열보다 enum/형식 제약이 환각을 줄인다.
4. **`required` 명시** — 빠지면 모델이 빈칸을 지어낸다.
5. **읽기/쓰기 도구 분리** — 쓰기 도구는 별도 승인 경로(§5)로 보낸다.

스키마 골격은 `templates/tool-schema.json` 참조. SDK 매핑:

| | Claude (`@anthropic-ai/sdk`) | Gemini (`@google/genai`) |
|---|---|---|
| 도구 전달 | `tools: [{ name, description, input_schema }]` | `tools: [{ functionDeclarations: [{ name, description, parameters }] }]` |
| 모델의 호출 | `content` 안 `tool_use` 블록 | `functionCall` part |
| 결과 반환 | `role:"user"` 의 `tool_result` 블록 | `functionResponse` part |
| 강제/자동 | `tool_choice: {type:"auto"|"any"|"tool"}` | `toolConfig.functionCallingConfig.mode: AUTO|ANY|NONE` |

> 2nd-Brain 등 Gemini 경유 프로젝트는 **반드시** `src/lib/llm/gemini.ts` 단일 경로(C1)로 호출하고, 매 호출 `ai_audit_log` INSERT(C3) + `classifyInput()` 선행(C9)을 지킨다.

## 3. 계획·실행 루프 (agentic loop)

표준 루프는 단순하다. 복잡하게 만들지 말 것:

```
state = { messages: [system, user], steps: 0 }
loop:
  resp = LLM(state.messages, tools)          # 1. 모델이 생각/도구호출 결정
  if resp 에 tool_call 없음:                  # 2. 최종 답 → 종료
      return resp.text
  for each tool_call in resp:                 # 3. 도구 실행
      guard(tool_call)                        #    가드레일 통과 검사(§5)
      result = run_tool(tool_call)            #    실패해도 throw 말고 결과로 회신
      state.messages += tool_call, result
  state.steps += 1
  if state.steps >= MAX_STEPS: break          # 4. 종료조건(§5)
```

실행 가능한 의사코드/타입은 `templates/agent-loop.ts` 참조.

설계 포인트:
- **도구 결과는 항상 모델에 되돌린다** — 에러도 `{ "error": "..." }` 형태로. 모델이 복구 시도하게.
- **병렬 도구 호출** — 한 턴에 여러 `tool_use` 가 오면 독립적인 건 동시 실행(Promise.all). 의존적이면 순차.
- **planning 분리(선택)** — 복잡하면 1턴은 "계획만 텍스트로", 이후 턴은 실행. 작은 작업엔 과잉.

## 4. 메모리 / 상태

| 종류 | 무엇 | 구현 |
|---|---|---|
| Working memory | 현재 루프의 message 배열 | in-memory, 요청 끝나면 폐기 |
| Episodic | 이전 대화/세션 | DB(turn 단위) + 요청 시 요약해 주입 |
| Long-term | 사용자 사실·선호 | 별도 store, 필요한 것만 retrieve 해 system 에 |
| Scratchpad | 중간 계산·계획 | message 안 텍스트 or 전용 `note` 도구 |

규칙:
- **컨텍스트 무한 누적 금지** — 턴이 길어지면 오래된 tool_result 를 요약·절단. 토큰=비용=지연.
- **상태는 직렬화 가능하게** — 루프 중단/재개(예: 사람 승인 대기) 위해 state 를 저장·복원 가능한 형태로.
- 영속 메모리가 DB 면 스키마를 사용자 프로젝트 규약에 맞춰라(2nd-Brain: Supabase + RLS, 새 함수는 `REVOKE ... FROM anon` 명시).

## 5. 가드레일 · 종료조건 · 루프 방지 (가장 중요)

에이전트의 실패는 대부분 **무한루프**와 **도구 오용**이다. 아래는 협상 불가:

| 가드 | 규칙 |
|---|---|
| Max steps | 루프 하드 상한(예: 8~12). 초과 시 강제 종료 + "한도 도달" 반환 |
| Budget cap | 누적 토큰/비용 상한. 초과 시 즉시 중단 |
| No-progress 감지 | 같은 도구를 같은 인자로 2회 반복 호출 → 루프로 간주, 차단 |
| 도구 화이트리스트 | 모델이 정의되지 않은 도구명을 부르면 실행 금지, 에러 회신 |
| 인자 검증 | 실행 전 JSON Schema 로 인자 validate. 실패 시 에러 회신(throw 금지) |
| 쓰기 승인 게이트 | 되돌릴 수 없는 도구(결제/삭제/발송)는 실행 전 사람 승인 또는 dry-run |
| 출력 안전 | 도구 결과·최종 출력에 프롬프트 인젝션/PII 누출 검사 |
| 타임아웃 | 도구별 timeout. 외부 API 무한 대기 차단 |

루프 방지 구현 골격은 `scripts/guardrails.ts` 참조(step/budget/중복호출 카운터).

> **위험 경고로 항상 표시할 것**: ① 무한루프(상한 없는 while) ② 도구 오용(검증 없는 인자로 쓰기 도구 호출) ③ 프롬프트 인젝션(도구 결과를 그대로 신뢰). 이 셋은 코드 리뷰에서 기본 점검 항목.

## 6. 멀티에이전트 패턴

단일 에이전트로 안 되면(역할·도구셋이 충돌하거나 컨텍스트가 비대) 분리. 토폴로지 선택:

| 패턴 | 구조 | 언제 |
|---|---|---|
| **Fan-out (병렬)** | 1 → N 동시 실행 → 결과 합침 | 하위 작업이 서로 독립 (예: 3개 소스 동시 리서치) |
| **Pipeline (순차)** | A 출력 → B 입력 → C | 단계별 가공, 각 단계가 다음의 입력 |
| **Supervisor (라우팅)** | 상위가 분류 → 전문 에이전트로 위임 | 도메인이 갈림 (검색/계산/작성 전문가) |

설계 시 각 에이전트의 **입력 컨텍스트는 최소화, 출력은 계약(contract)으로 고정**한다 — 이 분해·envelope·contract 원칙은 `agent-delegate`(SimonKCore)와 동일하므로 그쪽 4단계 프로토콜을 그대로 적용. 차이: agent-delegate 는 Claude Code 세션 내부 위임, 여기는 사용자 앱의 런타임 에이전트.

멀티에이전트 추가 가드:
- 에이전트 간 호출도 **깊이 상한**을 둔다(A→B→A 순환 차단).
- 합치는 로직 없는 fan-out 금지(병렬 결과를 버리는 안티패턴).

## 7. 관측성 · 비용 상한

출하 전 반드시 계측:

- **trace 로깅** — 매 턴: 모델 응답, 호출된 도구·인자, 도구 결과, 누적 토큰. 1 요청 = 1 trace id.
- **비용 미터** — in/out 토큰 × 모델 단가 누적. 요청·일·사용자 단위 상한. (단가/모델 ID 확인은 `model-router` 또는 `claude-api` skill.)
- **실패율 대시보드** — 도구별 에러율, max-steps 도달률, 평균 턴 수. 이상 급증 = 회귀.
- **평가 루프** — 골든 케이스 세트로 회귀 테스트. 정량 평가는 `llm-eval` skill 연계.

## 8. 구현 산출 순서 (권장)

1. §1 진단 확정 → 2. `templates/tool-schema.json` 으로 도구 스키마 작성 → 3. `templates/agent-loop.ts` 로 루프 구현 → 4. `scripts/guardrails.ts` 로 상한·검증 삽입 → 5. trace 로깅 추가 → 6. 골든 케이스로 평가.

각 단계 후 사용자에게 확인. 5개 파일 한도(프로젝트 Context Guardian 규칙) 내에서 작업하고, 한 기능 단위로 끊어 커밋 권고.

## 9. 안티패턴

- ❌ 상한 없는 `while (true)` 루프 — 무한루프·비용 폭발
- ❌ 도구 인자 검증 없이 쓰기 도구 실행
- ❌ 도구 에러를 throw 로 죽임 (모델이 복구 못 함 → 결과로 회신해야)
- ❌ description 부실한 도구 (모델이 오용)
- ❌ 고정 워크플로면 되는데 에이전트로 과설계
- ❌ 도구 결과(외부 텍스트)를 검증 없이 신뢰 (프롬프트 인젝션)
- ❌ 컨텍스트 무한 누적 (요약·절단 없음)
- ❌ 멀티에이전트 순환 깊이 무제한

## 10. 관련 스킬

- `agent-delegate` (SimonKCore) — Claude Code **세션 내부** 작업 위임. 분해·envelope·contract 원칙 공유 (§6 적용)
- `model-router` — task 별 best 모델·API ID·단가 선택
- `claude-api` — Claude tool_use / MCP / 토큰·캐싱·모델 ID 레퍼런스
- `llm-eval` — 에이전트 출력 정량 평가·회귀 테스트
- `authz-designer` / `paid-api-guard` — 쓰기·결제 도구의 권한·비용 가드
