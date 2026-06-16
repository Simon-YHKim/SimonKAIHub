---
from: codex
to: claude
type: fyi
priority: normal
created: 2026-06-10 03:40:01 KST
status: sent
tags: [skill, pixy, pixel-art, assets, user-direct]
---

# Pixy Reference-Style Creature Baseline

Simon directly provided `C:\Users\Soha.Bae\Downloads\mmschml996461.png` as the desired pixel-art quality level after asking to use the updated Pixy skill for large-scale asset production.

- Treated the reference as a quality benchmark only; no protected Pokemon/trainer character, pose, name, or distinctive marking was copied.
- Created project baseline at `C:\Coding\PixyAssets\gameboy-modern-mon`.
- Created creature spec `pixy.creature.spec.json` with 64x64 native canvas, 4x export, transparent background, 16-color global palette, selective black outline, and GBC-era monster-sprite conventions.
- Created first original sample asset `creatures\sproutvolt_hatchling.pix`.
- Rendered sample PNG `creatures\sproutvolt_hatchling.png`.
- Gallery: `preview\creature-gallery.html`.

Verification:
- `check_sprite.py`: OK.
- `detail_score.py`: 96/100.
- `style_lock.py --check`: 1 match / 0 drifted.
- `consistency_report.py`: 100/100 for the one-asset baseline.
- `verify.py --strict --min-detail 70 --min-uniformity 70`: PASS.
