---
agent: grok
owner: grok
updated: 2026-06-13 19:04:07 KST
source: PROTOCOL.md §34.2 (lane golden set) · §34.6 (Grok loop)
status: active
related: agents/grok/autonomous-loop-rules.md, ../../loop-baseline.md
---

# Grok Golden Set — Fixed Research-Question Set + Reproducibility Rule

> **§34.5 Sync header**: Source of truth = `PROTOCOL.md` (§34.2 · §34.6); on conflict **PROTOCOL wins**. last-sync: **2026-06-13**.
>
> PROTOCOL §34.2 requires each AI to have a **fixed golden set (시험지)** so progress is *measured*, not "looks good". For Grok the golden set is a **fixed research-question set (same keywords + sources) + signal reproducibility (same conclusion on two passes)**. This file makes that measurable instead of abstract. Score sheet of record = hub `loop-baseline.md`.

---

## 1. The fixed questions (Q1–Q7 — do not silently reword)

> These are the canonical consumer/market questions for 2nd-B. **Keep the wording, keywords, and sources fixed** — if you change a question, it is a *new* test and old runs are no longer comparable (§12.1a "시험지가 바뀌면 점수 비교로 쓰지 않는다"). Each run answers the *same* questions against the *same* sources so signals are reproducible.

| # | Canonical question | Fixed search keywords |
|---|---|---|
| **Q1** | How do consumers react to **AI journaling / self-knowledge / "second brain" PKM** apps right now — enthusiasm vs fatigue vs distrust? | `AI journaling`, `second brain app`, `PKM`, `세컨드 브레인`, `AI 일기` |
| **Q2** | What **privacy / trust** objections show up against apps that read personal notes & feed them to an LLM? | `AI privacy notes`, `LLM reads my journal`, `data privacy journaling`, `개인정보 AI` |
| **Q3** | What **pricing / subscription sensitivity** signals exist for self-improvement / journaling apps (free vs paid, subscription fatigue)? | `subscription fatigue`, `journaling app worth paying`, `구독 피로`, `앱 구독 가격` |
| **Q4** | What **triggers sharing / virality** in the self-knowledge / personality / reflection space? | `personality test viral`, `self-knowledge share`, `MBTI share`, `성찰 공유` |
| **Q5** | How is **competitor / category perception** trending (Notion AI, Day One, Rewind/Limitless, Mem, Reflect, etc.)? | `Notion AI`, `Day One app`, `Rewind AI`, `Reflect notes`, `Mem app` |
| **Q6** | What **generational / country** differences appear in attitudes toward AI self-reflection (KR vs US vs JP vs EU; Gen Z vs older)? | `Gen Z AI journaling`, `AI therapy attitudes`, `자기성찰 앱 세대`, country modifiers |
| **Q7** | What **honesty / clinical-framing** reactions exist — does "AI tells you the hard truth" attract or repel, and where is clinical language a taboo? | `brutally honest AI`, `AI tough love`, `clinical language app`, `솔직한 AI` |

(Use Q1–Q5 every run; add Q6–Q7 when the cycle touches generational/country or honesty-framing decisions. Minimum 5 questions per §34.2 "5–8 canonical questions".)

## 2. Canonical sources (fixed — same surfaces each pass)

> Pull from the **same source set** each pass so a changed conclusion reflects a real signal shift, not a different sampling surface.

1. **X / Twitter** — primary firehose (Grok's exclusive data moat, §0.2). Search the fixed keywords; weight by recent engagement (replies/quotes/likes), not raw volume.
2. **Reddit** — r/PKM, r/Notion, r/journaling, r/selfimprovement, r/Anki (and KR equivalents where relevant) for considered/long-form sentiment.
3. **App store reviews** — Day One, Notion, Reflect, Mem, Rewind/Limitless: recurring praise + recurring complaints.
4. **Product Hunt / Hacker News** — launch reception + skeptic objections for the category.
5. **KR surfaces** — for Q6 country split: relevant Korean community/blog signal (privacy + subscription tone differs from US).

## 3. Reproducibility rule (the pass/fail criterion)

> A signal **counts as a valid golden-set result only if it reproduces**:

- **Two-pass rule**: run the same question against the same sources **twice** (separated in time, or a second independent sweep). A signal is "valid" only if **both passes reach the same conclusion**. One-pass-only or pass-disagreement signals are logged as **unconfirmed**, not adopted.
- **Quality over volume**: weight by engagement and repetition across sources, not raw hit count. Discard fake/astroturfed/low-signal trends (§34.6 "avoid fake/low-signal trends").
- **Adoption counter (§34.6)**: each *valid* (two-pass-confirmed) insight that gets adopted counts toward the **N=5** threshold; reaching 5 adopted valid insights promotes Grok to a fully autonomous trend loop (via §14 consensus).
- **Failure ledger**: a question that yields no reproducible signal, or a signal that fails the second pass, is logged to hub `loop-baseline.md` §4 (failure ledger) — don't silently re-pitch the same dead lead; a re-pitch needs a new baseline / new evidence (§12.1a).
- **Separate judge (§34.4)**: Grok proposes; Claude (+ relevant lane) judges adoption. No self-declared "done" on Grok's own signal alone.

## 4. How a cycle uses this

```
0. (loop step 0 §12.1) read CONTROL/BOARD/inbox + re-read this golden-set on first cycle post-compaction (§34.5)
1. Pick the relevant question(s) Q1–Q7 for the current hub decision in flight
2. Pass A: search fixed keywords against the fixed source set (§2) → draft conclusion
3. Pass B: re-run independently → keep only conclusions that match Pass A (§3 two-pass rule)
4. Emit: outbox fyi/response (3–6 bullets + 1–2 key X signals w/ links) + HTML preview (§16)
5. Reusable consumer/market lesson → type: wiki_lesson (to: claude) for librarian ingest (§34.1)
6. Log adopted valid insights toward N=5; log dead/unreproduced leads to loop-baseline.md §4
```
