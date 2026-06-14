// shoot.mjs -- Shared 4-AI hub VISUAL QA: capture 2nd-B web screens and AUTO-DETECT
// black/blank renders. Born from a real miss (2026-06-14): AG's emulator QA reported
// "home PASS" while screen_main.png was pure black -- because its verdict leaned on
// logcat (no crash) + the UI tree, NOT on the pixels. This tool makes the pixels the
// verdict: a screen with no FATAL but a black/empty frame is a FAIL.
//
// Any AI runs it (Claude/Codex/Grok/AG). Claude/others then Read the PNGs to judge by eye.
//
//   node shoot.mjs                         # default base = live GitHub Pages (current main)
//   node shoot.mjs --base http://localhost:8081   # local expo web (npm run web in 2nd-B)
//   node shoot.mjs --out ./shots-r42 --screens screens.json
//
// Exit 0 = every captured screen rendered real content. Exit 2 = at least one BLACK/BLANK.
import { chromium } from 'playwright';
import { PNG } from 'pngjs';
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
function arg(name, def) {
  const i = process.argv.indexOf('--' + name);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : def;
}
const BASE = arg('base', 'https://simon-yhkim.github.io/2nd-B').replace(/\/+$/, '');
const OUT = resolve(HERE, arg('out', './shots'));
const SCREENS_FILE = resolve(HERE, arg('screens', 'screens.json'));
const VIEWPORT = { width: 414, height: 896 }; // phone-ish, matches the native QA framing

// A frame is BLACK if almost every pixel is near-black; BLANK if it rendered but carries
// almost no visible text. Either way the screen is not usefully showing content.
function analyzePng(buf) {
  const png = PNG.sync.read(buf);
  const { data, width, height } = png;
  let darkish = 0, total = 0, lumSum = 0;
  // sample a grid (fast, enough signal) ignoring the top status bar band
  const yStart = Math.floor(height * 0.06);
  for (let y = yStart; y < height; y += 4) {
    for (let x = 0; x < width; x += 4) {
      const idx = (width * y + x) << 2;
      const lum = 0.2126 * data[idx] + 0.7152 * data[idx + 1] + 0.0722 * data[idx + 2];
      lumSum += lum; total++;
      if (lum < 18) darkish++;
    }
  }
  return { meanLum: lumSum / total, darkFrac: darkish / total };
}

async function main() {
  const cfg = JSON.parse(readFileSync(SCREENS_FILE, 'utf8'));
  const screens = (cfg.screens || []).filter(s => s.auth === false); // web reaches unauth screens
  mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const ctx = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 2 });
  const page = await ctx.newPage();
  const results = [];
  for (const s of screens) {
    const url = BASE + s.path;
    const row = { name: s.name, url, verdict: 'OK', meanLum: 0, darkFrac: 0, textLen: 0, note: '' };
    try {
      await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });
      await page.waitForTimeout(1800); // let RN-web hydrate/animate in
      const text = (await page.evaluate(() => document.body && document.body.innerText || '')).trim();
      row.textLen = text.length;
      const file = join(OUT, s.name + '.png');
      const buf = await page.screenshot({ path: file, fullPage: false });
      const a = analyzePng(buf);
      row.meanLum = +a.meanLum.toFixed(1);
      row.darkFrac = +a.darkFrac.toFixed(3);
      if (a.darkFrac > 0.97 || a.meanLum < 6) { row.verdict = 'BLACK'; row.note = 'frame is near-all-black (content did not render)'; }
      else if (row.textLen < 12) { row.verdict = 'BLANK'; row.note = 'rendered but almost no visible text'; }
      else if (s.waitText && !text.includes(s.waitText)) { row.verdict = 'MISSING'; row.note = 'expected text not found: ' + s.waitText; }
    } catch (e) {
      row.verdict = 'ERROR'; row.note = String(e && e.message || e);
    }
    results.push(row);
    console.log(`  ${row.verdict.padEnd(7)} ${row.name.padEnd(10)} lum=${row.meanLum} dark=${row.darkFrac} text=${row.textLen}  ${row.note}`);
  }
  await browser.close();
  writeFileSync(join(OUT, 'verdict.json'), JSON.stringify({ base: BASE, viewport: VIEWPORT, results }, null, 2));
  const bad = results.filter(r => r.verdict !== 'OK');
  console.log(`\n  base=${BASE}  out=${OUT}`);
  console.log(`  ${results.length - bad.length}/${results.length} OK` + (bad.length ? `  -- FAIL: ${bad.map(b => b.name + '(' + b.verdict + ')').join(', ')}` : ''));
  process.exit(bad.length ? 2 : 0);
}
main().catch(e => { console.error(e); process.exit(1); });
