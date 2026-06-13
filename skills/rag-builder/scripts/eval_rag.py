"""RAG 평가 골격: 골든셋 -> 검색 -> 답변 -> 지표 집계.

지표:
  - Context Recall / Precision  : 골든셋 chunk id 매칭 (결정적, LLM 불필요)
  - Faithfulness / Answer Relevance : LLM-as-judge (Claude/Gemini)
  - Citation accuracy           : 인용 마커가 실제 근거와 일치하는지

검색/생성/judge 함수만 환경에 맞게 교체하면 된다.
파이프라인 변경 전후 동일 골든셋으로 before/after 비교 -> 회귀 방지.

사용:
  python eval_rag.py ../templates/eval_set.jsonl
"""
from __future__ import annotations

import json
import sys
from dataclasses import dataclass


@dataclass
class Retrieved:
    chunk_id: str
    content: str
    source: str


# ---------- 교체 지점 1: 검색 ----------
def retrieve(query: str, k: int = 5) -> list[Retrieved]:
    """hybrid_search 등 실제 파이프라인 검색으로 교체."""
    raise NotImplementedError("검색 파이프라인 연결 필요")


# ---------- 교체 지점 2: 답변 생성 ----------
def answer(query: str, ctx: list[Retrieved]) -> dict:
    """answer_prompt.md 구조화 출력 형식의 dict 반환:
    {answer, citations:[{id,...}], answered_from_context}.
    """
    raise NotImplementedError("생성 LLM 연결 필요")


# ---------- 교체 지점 3: LLM judge ----------
def judge(query: str, generated: str, ctx_text: str) -> dict:
    """faithfulness/relevance 를 0~1 로 채점. Claude/Gemini judge.
    반환: {"faithfulness": 0~1, "relevance": 0~1}.
    """
    raise NotImplementedError("judge 모델 연결 필요")


# ---------- 결정적 지표 ----------
def recall_precision(retrieved_ids: list[str], relevant_ids: list[str]) -> tuple[float, float]:
    if not relevant_ids:
        # 함정 질문(근거 없어야 정상): recall 정의상 1.0 로 둠
        return (1.0, 1.0 if not retrieved_ids else 0.0)
    rset, gset = set(retrieved_ids), set(relevant_ids)
    hit = len(rset & gset)
    recall = hit / len(gset)
    precision = hit / len(rset) if rset else 0.0
    return (recall, precision)


def citation_accuracy(result: dict, retrieved: list[Retrieved]) -> float:
    valid_ids = {str(i + 1) for i in range(len(retrieved))}
    cites = [str(c.get("id")) for c in result.get("citations", [])]
    if not cites:
        return 0.0
    return sum(1 for c in cites if c in valid_ids) / len(cites)


def main(path: str) -> None:
    rows = [json.loads(line) for line in open(path, encoding="utf-8") if line.strip()]
    agg = {"recall": 0.0, "precision": 0.0, "faithfulness": 0.0, "relevance": 0.0, "citation": 0.0}

    for r in rows:
        q = r["q"]
        retrieved = retrieve(q)
        rids = [x.chunk_id for x in retrieved]
        recall, precision = recall_precision(rids, r.get("relevant_chunk_ids", []))

        result = answer(q, retrieved)
        ctx_text = "\n".join(x.content for x in retrieved)
        scores = judge(q, result.get("answer", ""), ctx_text)

        agg["recall"] += recall
        agg["precision"] += precision
        agg["faithfulness"] += scores.get("faithfulness", 0.0)
        agg["relevance"] += scores.get("relevance", 0.0)
        agg["citation"] += citation_accuracy(result, retrieved)

    n = len(rows) or 1
    print("=== RAG eval (avg over %d) ===" % len(rows))
    for k, v in agg.items():
        print(f"  {k:14s}: {v / n:.3f}")
    print("회귀 방지: 파이프라인 변경 시 이 점수를 before/after 비교하세요.")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "../templates/eval_set.jsonl")
