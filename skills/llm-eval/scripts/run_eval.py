#!/usr/bin/env python3
"""run_eval.py — LLM 기능 평가 러너 (표준 라이브러리만). Python 환경 대안.

사용:
    python run_eval.py --set eval_set.jsonl --out runs/result.json --model gemini-2.x

입력 JSONL: 한 줄 = {"id","input","expected","tags","set"}
핵심: call_model() 을 사용자 앱의 실제 LLM 호출로 교체.
      judge 지표는 score_case() 안에서 별도 호출(judge_rubric.md 참고).
"""
import argparse, json, os, subprocess
from datetime import datetime, timezone


def load_jsonl(path):
    with open(path, encoding="utf-8") as f:
        return [json.loads(l) for l in f if l.strip()]


def git_sha():
    try:
        return subprocess.check_output(["git", "rev-parse", "--short", "HEAD"]).decode().strip()
    except Exception:
        return "nogit"


# ── 교체 지점 1: 앱의 실제 LLM 호출 ────────────────────────────────
def call_model(text):
    return str(text)  # TODO: replace with real app call


# ── 교체 지점 2: 채점 (룰 지표) ────────────────────────────────────
def score_case(actual, expected):
    exact = str(actual).strip() == str(expected).strip()
    try:
        json.loads(actual); json_valid = True
    except Exception:
        json_valid = False
    return {"exact": exact, "json_valid": json_valid}


def aggregate(rows):
    by_set = {}
    for r in rows:
        by_set.setdefault(r["set"] or "golden", []).append(r)
    out = {}
    for s, lst in by_set.items():
        n = len(lst)
        acc = sum(1 for r in lst if r["score"]["exact"]) / n
        out[s] = {"pass_rate": acc, "n": n} if s == "adversarial" else {"accuracy": round(acc, 4), "n": n}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--set", required=True, dest="setfile")
    ap.add_argument("--out", default="runs/result.json")
    ap.add_argument("--model", default="unknown")
    ap.add_argument("--label", default="run")
    a = ap.parse_args()

    rows = []
    for c in load_jsonl(a.setfile):
        actual = call_model(c["input"])
        rows.append({"id": c["id"], "set": c.get("set", "golden"), "actual": actual,
                     "expected": c["expected"], "score": score_case(actual, c["expected"])})

    result = {
        "run_id": f"{datetime.now(timezone.utc).isoformat()}-{a.label}",
        "git_sha": git_sha(),
        "model": a.model,
        "set_scores": aggregate(rows),
        "n_cases": len(rows),
        "failures": [{"id": r["id"], "set": r["set"]} for r in rows if not r["score"]["exact"]],
    }
    os.makedirs(os.path.dirname(a.out) or ".", exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print(json.dumps(result["set_scores"], ensure_ascii=False, indent=2))
    print(f"\n{len(rows)} cases -> {a.out}")


if __name__ == "__main__":
    main()
