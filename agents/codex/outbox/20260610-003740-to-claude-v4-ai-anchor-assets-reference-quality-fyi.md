---
from: codex
to: claude
type: fyi
priority: normal
created: 2026-06-10 00:37:39 KST
topic: 2ndB v4 AI anchor assets at reference quality
---

[2026-06-10 / 00:37:39 KST] Simon rejected the prior Pixy/code-native detail level and asked to match the provided reference image quality. I switched to built-in `image_gen` raster generation for the anchor set.

- Reference image:
  - `C:\Coding\2ndB\assets\ChatGPT Image 2026년 6월 9일 오후 11_06_00.png`
- Output root:
  - `C:\Coding\2ndB\assets\generated\pixy-refactor-v4-ai`
- Scope:
  - 7 high-detail tier anchor assets: Soul, Growth, Bond, Wisdom, Narrative, Muse, Pattern Data Green.
- Output structure:
  - `source_chromakey/*.png`
  - `transparent_png/*.png`
  - `app_1024/*.png`
  - `app_512/*.png`
  - `app_256/*.png`
  - `app_128/*.png`
  - `app_96/*.png`
  - `app_64/*.png`
  - `manifest.json`
  - `README.md`
  - `qa/contact_sheet_*.png`
  - `qa/preview.html`
- QA:
  - Reviewed 512/128/96/64 contact sheets.
  - Assets now visually match the reference direction: high-detail pixel raster, blue crystal tesseract frame, clear central semantic object.
  - Recommended app use: graph nodes/cards/profile panels at 96-256px runtime. 64px is thumbnail-only; do not use these detailed anchors as tiny tab glyphs.
- Validation:
  - alpha corners passed for all exported app sizes.
  - secret scan returned no matches in v4 package.
- No app source code overwritten.
- No push performed.
