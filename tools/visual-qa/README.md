# hub visual-qa — pixel-based UI verification for any AI

Shared tool so **any hub AI (Claude / Codex / Grok / Antigravity)** verifies 2nd-B UI by the
**pixels that actually render**, not by "no crash in the logs". It exists because of a real
miss (2026-06-14): AG reported the home screen "PASS" while the captured frame was pure
black — the verdict had leaned on logcat + the accessibility tree, never on the image.

## Rule this enforces
A screen is **FAIL** if its frame is black/empty **even when nothing crashed**. No-FATAL ≠ rendered.

## Run
```bash
cd "E:/Coding Infra/AI Infra/Communication/tools/visual-qa"
npm install            # one-time: playwright + pngjs
npx playwright install chromium   # one-time: the browser
npm run shoot                      # default base = live GitHub Pages (current main)
# or local expo web (run `npm run web` in E:/2ndB first):
node shoot.mjs --base http://localhost:8081 --out ./shots-local
```

Output: `shots/<screen>.png` + `shots/verdict.json`. Per screen it reports
`meanLum` (mean luminance), `darkFrac` (fraction near-black), `textLen` (visible text),
and a verdict: `OK | BLACK | BLANK | MISSING | ERROR`. Exit 2 if any screen is not OK.

## Who judges what (Simon, 2026-06-14)
Split the verdict by what each step is good at:
- **Capture + black/blank gate (objective): Claude** runs `shoot.mjs`. `meanLum`/`darkFrac`/
  `textLen` are measurements, not opinions — a black/empty frame is a mechanical FAIL here
  regardless of crash logs.
- **In-image detail judgment (what's actually on the screen — copy correctness, layout,
  hierarchy, the 4 UX axes): Codex + Antigravity.** They read the captured PNGs and are the
  **authority** on detailed content; **do not** substitute Claude's own eyeball read for theirs.
- **Aggregate + act: Claude** collects Codex's + AG's per-screen verdicts and proceeds on them.

So the loop is: Claude captures fresh PNGs + gates black/blank -> hands the PNGs to Codex and
AG -> they return **per-screen** content verdicts (fresh shot each, never a blanket "all PASS")
-> Claude aggregates and acts.

## Coverage
`screens.json` lists the key screens. `auth:false` screens (sign-in, sign-up/consent,
landing) are reachable by web capture. `auth:true` screens (home, capture, persona) need a
logged-in/seeded session — covered by **AG native emulator** capture today (a seeded web
session is a future add). Keep `screens.json` in sync with the real expo-router routes.

## For the other AIs
- **Codex + Antigravity** are the in-image-detail authority. Given fresh PNGs (web shots
  here, or AG's native captures for `auth:true` screens), return a **per-screen** verdict:
  is the content correct (copy, layout, hierarchy, the 4 UX axes), what's wrong, what's the
  fix. One fresh shot per screen; never a blanket "all PASS"; assert content rendered (not
  just "no ANR"). Do not reuse old grabs.
- **Grok**: market/consumer lens on the same shots if asked.
- **Claude**: capture + black/blank gate + aggregate Codex/AG verdicts; does not override
  their content read.
