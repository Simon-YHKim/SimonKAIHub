#!/usr/bin/env node
// run_eval.mjs — LLM 기능 평가 러너 (의존성 0, Node 18+).
//
// 사용:
//   node run_eval.mjs --set eval_set.jsonl --out runs/result.json
//
// 입력: JSONL (한 줄 = {id, input, expected, tags, set})
// 동작: callModel() 로 각 케이스를 평가 대상 함수에 통과시키고,
//       scoreCase() 로 룰 지표 채점 → set별 점수 집계 → result.json 기록.
//
// 핵심: callModel() 을 "사용자 앱의 실제 LLM 호출 함수"로 교체한다.
//       (예: src/lib/llm/gemini.ts 의 분류/요약 함수를 import)
// judge 지표가 필요하면 scoreCase() 안에서 별도 judge 호출을 추가한다(judge_rubric.md 참고).

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";
import { execSync } from "node:child_process";

function parseArgs(argv) {
  const a = {};
  for (let i = 2; i < argv.length; i++) {
    const k = argv[i];
    if (k.startsWith("--")) a[k.slice(2)] = argv[i + 1]?.startsWith("--") ? true : argv[++i];
  }
  return a;
}

function loadJsonl(path) {
  return readFileSync(path, "utf8")
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean)
    .map((l) => JSON.parse(l));
}

function gitSha() {
  try { return execSync("git rev-parse --short HEAD").toString().trim(); }
  catch { return "nogit"; }
}

// ─── 교체 지점 1: 앱의 실제 LLM 호출 ───────────────────────────────
// 여기서 사용자 앱의 함수를 호출하도록 바꾼다. 지금은 echo stub.
async function callModel(input) {
  return String(input); // TODO: replace with real app call
}

// ─── 교체 지점 2: 채점 ────────────────────────────────────────────
// 룰 지표 예시. task 유형에 맞게 확장한다.
function scoreCase(actual, expected) {
  const exact = String(actual).trim() === String(expected).trim();
  let jsonValid = true;
  try { JSON.parse(actual); } catch { jsonValid = false; }
  return { exact, jsonValid };
}

function aggregate(rows) {
  const bySet = {};
  for (const r of rows) {
    const s = r.set || "golden";
    (bySet[s] ??= []).push(r);
  }
  const out = {};
  for (const [s, list] of Object.entries(bySet)) {
    const n = list.length;
    const acc = list.filter((r) => r.score.exact).length / n;
    out[s] = s === "adversarial"
      ? { pass_rate: acc, n }
      : { accuracy: Number(acc.toFixed(4)), n };
  }
  return out;
}

async function main() {
  const args = parseArgs(process.argv);
  if (!args.set) { console.error("usage: run_eval.mjs --set <file.jsonl> --out <result.json>"); process.exit(2); }
  const cases = loadJsonl(args.set);
  const rows = [];
  for (const c of cases) {
    const actual = await callModel(c.input);
    rows.push({ id: c.id, set: c.set, tags: c.tags ?? [], actual, expected: c.expected, score: scoreCase(actual, c.expected) });
  }
  const result = {
    run_id: `${new Date().toISOString()}-${args.label ?? "run"}`,
    git_sha: gitSha(),
    model: args.model ?? "unknown",
    set_scores: aggregate(rows),
    n_cases: rows.length,
    failures: rows.filter((r) => !r.score.exact).map((r) => ({ id: r.id, set: r.set })),
  };
  const out = args.out ?? "runs/result.json";
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, JSON.stringify(result, null, 2));
  console.log(JSON.stringify(result.set_scores, null, 2));
  console.log(`\n${rows.length} cases → ${out}`);
}

main();
