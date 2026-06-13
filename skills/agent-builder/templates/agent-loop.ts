/**
 * agent-loop.ts — tool-use 에이전트 루프 골격 (벤더 무관 의사 구현).
 *
 * Claude:  resp.content 의 tool_use 블록 → tool_result 블록으로 회신
 * Gemini:  resp 의 functionCall part → functionResponse part 로 회신
 *
 * 핵심: 도구 결과는 (성공/실패 모두) 항상 모델에 되돌린다. 에러로 throw 하면 모델이 복구 못 한다.
 * 가드레일은 ./scripts/guardrails 를 참조 — max steps / budget / 중복호출 / 인자검증 / 승인게이트.
 */

type ToolCall = { id: string; name: string; args: Record<string, unknown> };
type LLMResponse = { text?: string; toolCalls: ToolCall[]; usage: { in: number; out: number } };

interface ModelClient {
  // 메시지 + 도구 스키마 → 모델 응답 (벤더별 구현으로 감싼다)
  generate(messages: unknown[], tools: unknown[]): Promise<LLMResponse>;
}

interface ToolRegistry {
  has(name: string): boolean;
  validate(name: string, args: unknown): { ok: true } | { ok: false; error: string };
  requiresApproval(name: string): boolean;
  run(name: string, args: Record<string, unknown>): Promise<unknown>; // timeout 은 구현 내부에서
}

interface Guard {
  beforeTurn(): { stop: true; reason: string } | { stop: false };
  recordUsage(u: { in: number; out: number }): void;
  isDuplicate(call: ToolCall): boolean; // 같은 도구·같은 인자 반복 = 루프
}

export async function runAgent(opts: {
  model: ModelClient;
  tools: ToolRegistry;
  toolSchemas: unknown[];
  guard: Guard;
  messages: unknown[];                                  // [system, user, ...]
  approve?: (call: ToolCall) => Promise<boolean>;       // 쓰기 도구 승인 콜백
}): Promise<{ text: string; reason: "final" | "max_steps" | "budget" }> {
  const { model, tools, toolSchemas, guard, messages, approve } = opts;

  for (;;) {
    const gate = guard.beforeTurn();                    // max steps / budget 상한
    if (gate.stop) return { text: `[중단: ${gate.reason}]`, reason: gate.reason.includes("budget") ? "budget" : "max_steps" };

    const resp = await model.generate(messages, toolSchemas);
    guard.recordUsage(resp.usage);
    messages.push({ role: "assistant", content: resp });

    if (resp.toolCalls.length === 0) {                  // 도구 호출 없음 → 최종 답
      return { text: resp.text ?? "", reason: "final" };
    }

    // 한 턴의 도구 호출들: 독립적이면 병렬, 의존적이면 순차로 바꿔라
    const results = await Promise.all(
      resp.toolCalls.map(async (call): Promise<{ id: string; output: unknown }> => {
        // 1) 화이트리스트
        if (!tools.has(call.name)) return { id: call.id, output: { error: `unknown tool: ${call.name}` } };
        // 2) 인자 검증 (throw 금지 — 에러를 결과로)
        const v = tools.validate(call.name, call.args);
        if (!v.ok) return { id: call.id, output: { error: v.error } };
        // 3) 루프 방지: 동일 호출 반복 차단
        if (guard.isDuplicate(call)) return { id: call.id, output: { error: "duplicate call blocked (no progress)" } };
        // 4) 쓰기 승인 게이트
        if (tools.requiresApproval(call.name)) {
          const ok = approve ? await approve(call) : false;
          if (!ok) return { id: call.id, output: { error: "approval denied" } };
        }
        // 5) 실행 (timeout 은 registry 내부) — 실패해도 결과로 회신
        try {
          return { id: call.id, output: await tools.run(call.name, call.args) };
        } catch (e) {
          return { id: call.id, output: { error: String((e as Error).message ?? e) } };
        }
      }),
    );

    messages.push({ role: "tool", content: results });  // 벤더별 tool_result/functionResponse 로 매핑
  }
}
