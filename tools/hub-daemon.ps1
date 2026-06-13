# hub-daemon.ps1 -- Autonomous 4-AI hub driver (PROTOCOL section 12/19/35.4).
# Makes Codex/Grok (and optionally Antigravity) keep investigating on their own:
# each cycle it asks every AI to read its inbox + do the next task in its lane +
# commit, then stamps a STATUS heartbeat so the monitor reflects REAL freshness
# (this is the fix for "codex stale 59m" -- the AI not self-updating STATUS).
# Claude stays the merge gate; AIs never push 2nd-B (branch/outbox only).
#
# Why sequential: the hub is a LOCAL-ONLY shared git tree. One git writer at a
# time avoids .git index.lock races (commit.ps1 has no lock-retry). No fetch/pull
# needed -- every AI shares the same working directory.
#
# Launch (background, this session):
#   powershell -ExecutionPolicy Bypass -File tools/hub-daemon.ps1
#   powershell -ExecutionPolicy Bypass -File tools/hub-daemon.ps1 -IntervalSec 300 -IncludeAG
#   powershell -ExecutionPolicy Bypass -File tools/hub-daemon.ps1 -MaxCycles 1   # single test cycle
# Stop: kill the background task (TaskStop) or Ctrl+C in its terminal.
param(
  [int]$IntervalSec = 300,
  [int]$MaxCycles = 0,         # 0 = run forever
  [switch]$IncludeAG           # off by default: gemini hits 429 capacity limits
)
$ErrorActionPreference = 'Continue'
$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8
$root = Split-Path $PSScriptRoot -Parent
$daemonLog = Join-Path $root "tools\hub-daemon.log"

function Now { Get-Date -Format 'yyyy-MM-dd HH:mm:ss' }
function Log([string]$m){
  $line = "[$(Now) KST] $m"
  Write-Host $line
  try { Add-Content -LiteralPath $daemonLog -Value $line -Encoding utf8 } catch {}
}
# Guaranteed STATUS heartbeat: update updated:/state: in-place (UTF-8 no BOM).
# The monitor's mtime fallback then shows the AI as fresh even if its own CLI
# run forgot to touch STATUS. Sequential, so no concurrent writer.
function Set-Heartbeat([string]$ai){
  $sf = Join-Path $root ("agents\" + $ai + "\STATUS.md")
  if(-not (Test-Path -LiteralPath $sf)){ return }
  $lines = @(Get-Content -LiteralPath $sf -Encoding UTF8)
  $ts = Now
  for($i=0;$i -lt $lines.Count;$i++){
    if($lines[$i] -match '^\s*updated:'){ $lines[$i] = "updated: $ts KST" }
    elseif($lines[$i] -match '^\s*state:'){ $lines[$i] = "state: running" }
  }
  [System.IO.File]::WriteAllLines($sf, $lines, $utf8)
}

$AIs = @('codex','grok')
if($IncludeAG){ $AIs += 'antigravity' }

function Invoke-AI([string]$ai){
  # Single-line, NO embedded double-quotes: PS 5.1 mangles native-exe arguments
  # that contain " or span lines (this broke grok+codex in the first test).
  # Paths are plain text; the AI quotes them itself when it runs commands.
  $lane = switch($ai){
    'codex'       { "codex lane = 2nd-B UI/anti-slop/bug-QA/native-safety; work in a git worktree off origin/main, branch only, do NOT push (Claude is the merge gate), submit to agents/codex/outbox." }
    'grok'        { "grok lane = market/X/consumer-signal advisory; written advisory text only, no code." }
    'antigravity' { "antigravity lane = native/emulator QA; report findings only, no push." }
  }
  $prompt = "You are $ai in the 4-AI hub (root: $root). Run ONE autonomous poll cycle (PROTOCOL 12/19/35.4). Step 1: read your inbox with tools/board.ps1 -Me $ai and scan agents/*/outbox for OPEN requests addressed to $ai or all. Step 2: if an open order exists do the next one, otherwise autonomously do the single most valuable task in your lane per BOARD.md current focus. Step 3 constraints: single-writer (write only agents/$ai/ in the hub), NEVER push 2nd-B, no destructive/cost/secrets actions (escalate to Claude via outbox), apply section 35 self-panel, ONE task only this cycle. Step 4: commit hub output via tools/commit.ps1 -As $ai -Message <conventional msg> -Files <your files> (quote paths containing spaces), then refresh agents/$ai/STATUS.md with a fresh updated stamp and one activity line. Timestamps via Get-Date KST. $lane"
  switch($ai){
    'codex'       { "" | codex exec -s danger-full-access --skip-git-repo-check -C $root -c model_reasoning_effort=high $prompt }
    'grok'        { grok -p $prompt }
    'antigravity' { gemini -p $prompt -y }
  }
  Log "cycle exit($ai)=$LASTEXITCODE"
}

Log "hub-daemon START interval=${IntervalSec}s AIs=$($AIs -join ',') maxCycles=$MaxCycles"
$cycle = 0
while($true){
  $cycle++
  Log "cycle $cycle BEGIN"
  foreach($ai in $AIs){
    Log "cycle $cycle -> $ai poll"
    try { Invoke-AI $ai } catch { Log "cycle $cycle $ai ERROR: $($_.Exception.Message)" }
    try { Set-Heartbeat $ai } catch { Log "cycle $cycle $ai heartbeat ERROR: $($_.Exception.Message)" }
  }
  Log "cycle $cycle END"
  if($MaxCycles -gt 0 -and $cycle -ge $MaxCycles){ Log "reached MaxCycles=$MaxCycles, stopping"; break }
  Start-Sleep -Seconds $IntervalSec
}
