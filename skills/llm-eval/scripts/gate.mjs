#!/usr/bin/env node
// gate.mjs — 회귀 게이트. baseline 대비 결과를 판정해 CI 를 통과/차단한다.
//
// 사용:
//   node gate.mjs --baseline runs/baseline.json --result runs/result.json
//   node gate.mjs --baseline runs/baseline.json --result runs/result.json --update-baseline
//
// 규칙(기본값, 인자로 조정):
//   --drop 0.02   골든/엣지 정확도가 baseline 대비 이만큼 하락하면 fail (기본 2%p)
//   적대셋(pass_rate) 하락은 허용 0 → 즉시 fail
// exit 0 = 통과, 1 = 회귀, 2 = 사용법 오류

import { readFileSync, writeFileSync, copyFileSync } from "node:fs";

function parseArgs(argv) {
  const a = {};
  for (let i = 2; i < argv.length; i++) {
    const k = argv[i];
    if (k.startsWith("--")) a[k.slice(2)] = argv[i + 1]?.startsWith("--") || argv[i + 1] === undefined ? true : argv[++i];
  }
  return a;
}

const args = parseArgs(process.argv);
if (!args.baseline || !args.result) {
  console.error("usage: gate.mjs --baseline <b.json> --result <r.json> [--drop 0.02] [--update-baseline]");
  process.exit(2);
}

const drop = Number(args.drop ?? 0.02);
const result = JSON.parse(readFileSync(args.result, "utf8"));

if (args["update-baseline"]) {
  copyFileSync(args.result, args.baseline);
  console.log(`baseline updated from ${args.result} (의도된 개선으로 명시 승인됨)`);
  process.exit(0);
}

let baseline;
try { baseline = JSON.parse(readFileSync(args.baseline, "utf8")); }
catch {
  console.log("baseline 없음 → 이번 결과를 baseline 으로 저장 (첫 run)");
  writeFileSync(args.baseline, JSON.stringify(result, null, 2));
  process.exit(0);
}

const fails = [];
for (const [set, cur] of Object.entries(result.set_scores)) {
  const base = baseline.set_scores?.[set];
  if (!base) continue;
  if (set === "adversarial") {
    if ((cur.pass_rate ?? 1) < (base.pass_rate ?? 1) - 1e-9)
      fails.push(`[adversarial] pass_rate ${base.pass_rate} → ${cur.pass_rate} (허용 0 — 새 취약점)`);
  } else {
    const d = (base.accuracy ?? 0) - (cur.accuracy ?? 0);
    if (d > drop + 1e-9)
      fails.push(`[${set}] accuracy ${base.accuracy} → ${cur.accuracy} (−${d.toFixed(4)} > 허용 ${drop})`);
  }
}

if (fails.length) {
  console.error("회귀 감지 — FAIL\n" + fails.map((f) => "  - " + f).join("\n"));
  console.error("\n의도된 개선이면: gate.mjs ... --update-baseline 으로 명시 승인");
  process.exit(1);
}
console.log("회귀 없음 — PASS");
process.exit(0);
