/**
 * guardrails.ts — 에이전트 루프 안전 가드 구현 골격.
 *
 * 막는 3대 실패: ① 무한루프(상한 없는 while) ② 도구 오용(검증 없는 인자) ③ no-progress 반복.
 * agent-loop.ts 의 Guard 인터페이스를 만족한다. 프로젝트 단가/모델 ID 는 model-router·claude-api 참조.
 */

export interface GuardConfig {
  maxSteps: number;        // 루프 하드 상한 (권장 8~12)
  maxTokens: number;       // 누적 in+out 토큰 상한
  maxCostUsd: number;      // 누적 비용 상한 (USD)
  priceInPerMTok: number;  // 입력 1M 토큰당 단가
  priceOutPerMTok: number; // 출력 1M 토큰당 단가
}

type ToolCall = { name: string; args: Record<string, unknown> };

export class Guardrails {
  private steps = 0;
  private tokIn = 0;
  private tokOut = 0;
  private seen = new Set<string>(); // 호출 지문(이름+정규화 인자)

  constructor(private cfg: GuardConfig) {}

  /** 매 턴 시작 전 호출. 상한 도달 시 stop. */
  beforeTurn(): { stop: true; reason: string } | { stop: false } {
    this.steps += 1;
    if (this.steps > this.cfg.maxSteps) return { stop: true, reason: `max_steps(${this.cfg.maxSteps}) reached` };
    if (this.tokIn + this.tokOut > this.cfg.maxTokens) return { stop: true, reason: `budget tokens(${this.cfg.maxTokens}) exceeded` };
    if (this.costUsd() > this.cfg.maxCostUsd) return { stop: true, reason: `budget cost($${this.cfg.maxCostUsd}) exceeded` };
    return { stop: false };
  }

  recordUsage(u: { in: number; out: number }): void {
    this.tokIn += u.in;
    this.tokOut += u.out;
  }

  costUsd(): number {
    return (this.tokIn / 1e6) * this.cfg.priceInPerMTok + (this.tokOut / 1e6) * this.cfg.priceOutPerMTok;
  }

  /** 같은 도구를 같은 인자로 다시 부르면 진전 없음 = 루프로 간주. */
  isDuplicate(call: ToolCall): boolean {
    const fp = call.name + ":" + stableStringify(call.args);
    if (this.seen.has(fp)) return true;
    this.seen.add(fp);
    return false;
  }

  snapshot() {
    return { steps: this.steps, tokIn: this.tokIn, tokOut: this.tokOut, costUsd: this.costUsd() };
  }
}

/** 인자 순서에 무관한 안정 직렬화 (지문 비교용). */
function stableStringify(v: unknown): string {
  if (v === null || typeof v !== "object") return JSON.stringify(v);
  if (Array.isArray(v)) return "[" + v.map(stableStringify).join(",") + "]";
  const keys = Object.keys(v as Record<string, unknown>).sort();
  return "{" + keys.map((k) => JSON.stringify(k) + ":" + stableStringify((v as Record<string, unknown>)[k])).join(",") + "}";
}

/* 사용 예
const guard = new Guardrails({
  maxSteps: 10, maxTokens: 200_000, maxCostUsd: 0.50,
  priceInPerMTok: 3, priceOutPerMTok: 15,   // 예: Sonnet 급 단가 — 실제값은 model-router 확인
});
*/
