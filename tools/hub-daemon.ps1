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
  [int]$IntervalSec = 600,         # default 10min (Simon: all loops 10min)
  [int]$MaxCycles = 0,             # 0 = run forever
  [int]$MaxTasksPerCycle = 1,      # anti-idle: drain up to N OPEN orders per cycle before sleeping
  [switch]$IncludeAG,              # add antigravity (gemini seat) to the default codex,grok loop
  [string[]]$Only = @()            # run ONLY these AIs (e.g. -Only antigravity for a separate slow AG loop)
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

if($Only.Count -gt 0){ $AIs = $Only } else { $AIs = @('codex','grok'); if($IncludeAG){ $AIs += 'antigravity' } }

# Quota backoff state: when an AI's CLI returns a 429/quota-exhausted error (e.g. the gemini
# AG seat hits TerminalQuotaError with an 8h reset), stop hammering it every cycle. Each
# consecutive quota failure doubles the cycles skipped (cap 48 ~= 8h at 10min); a clean run
# resets it. Without this the AG daemon burned a spawn every 10min for 8h producing nothing.
$quotaSkip    = @{}   # ai -> cycles still to skip
$quotaStrikes = @{}   # ai -> consecutive quota failures
foreach($a in $AIs){ $quotaSkip[$a] = 0; $quotaStrikes[$a] = 0 }

# Count OPEN request orders addressed to this AI (lightweight frontmatter scan). Used to decide
# whether a drain (extra task this cycle) is warranted -- no open orders => no busywork.
function Count-OpenOrders([string]$ai){
  $n = 0
  Get-ChildItem (Join-Path $root "agents") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $obx = Join-Path $_.FullName "outbox"
    if(Test-Path $obx){
      Get-ChildItem $obx -Filter *.md -File -ErrorAction SilentlyContinue | ForEach-Object {
        $h = Get-Content $_.FullName -Encoding UTF8 -TotalCount 12
        $to=""; $ty=""; $stt=""
        foreach($l in $h){
          if($l -match '^to:\s*"?(.*?)"?\s*$'){ $to=$matches[1] }
          elseif($l -match '^type:\s*"?(.*?)"?\s*$'){ $ty=$matches[1] }
          elseif($l -match '^status:\s*"?(.*?)"?\s*$'){ $stt=$matches[1] }
        }
        if(($to -eq $ai -or $to -eq 'all') -and $ty -eq 'request' -and $stt -eq 'open'){ $n++ }
      }
    }
  }
  return $n
}

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
  $liveDir = Join-Path $root "tools\live"
  if(-not (Test-Path $liveDir)){ New-Item -ItemType Directory -Force $liveDir | Out-Null }
  $live = Join-Path $liveDir ($ai + ".log")
  $out = switch($ai){
    'codex'       { ("" | codex exec -s danger-full-access --skip-git-repo-check -C $root -c model_reasoning_effort=high $prompt) 2>&1 | Out-String }
    'grok'        { (grok -p $prompt) 2>&1 | Out-String }
    'antigravity' { (gemini -p $prompt -y) 2>&1 | Out-String }
  }
  $code = $LASTEXITCODE
  # Detect quota/rate-limit exhaustion so the caller can back off instead of re-spawning.
  $quota = ($out -match 'QUOTA_EXHAUSTED|RESOURCE_EXHAUSTED|TerminalQuotaError|exhausted your capacity|"code":\s*429|429 ')
  Log "cycle exit($ai)=$code$(if($quota){' QUOTA'})"
  # Keep the last ~45 non-empty lines (the AI's closing summary = its "what I just did")
  # as a live transcript -- written UTF-8 (Korean-safe) so feed.ps1 can show it like a chat message.
  $tail = (($out -split "`r?`n") | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 45) -join "`n"
  try { [System.IO.File]::WriteAllText($live, "[$(Now) KST] $ai (exit $code$(if($quota){' QUOTA-EXHAUSTED'}))`n`n$tail`n", $utf8) } catch {}
  return [pscustomobject]@{ Code = $code; Quota = [bool]$quota }
}

Log "hub-daemon START interval=${IntervalSec}s AIs=$($AIs -join ',') maxTasks=$MaxTasksPerCycle maxCycles=$MaxCycles"
$cycle = 0
while($true){
  $cycle++
  Log "cycle $cycle BEGIN"
  foreach($ai in $AIs){
    # Quota backoff: skip this AI while its backoff window is open (e.g. gemini 429 / 8h reset).
    if($quotaSkip[$ai] -gt 0){
      $quotaSkip[$ai]--
      Log "cycle $cycle -> $ai SKIP (quota backoff, $($quotaSkip[$ai]) cycles left)"
      continue
    }
    # Anti-idle drain: do the first task, then keep going while OPEN orders remain for this AI,
    # up to MaxTasksPerCycle. With no open orders this is exactly one self-directed task (no busywork).
    $task = 0
    while($task -lt $MaxTasksPerCycle){
      $task++
      Log "cycle $cycle -> $ai poll (task $task/$MaxTasksPerCycle)"
      $res = $null
      try { $res = Invoke-AI $ai } catch { Log "cycle $cycle $ai ERROR: $($_.Exception.Message)" }
      try { Set-Heartbeat $ai } catch { Log "cycle $cycle $ai heartbeat ERROR: $($_.Exception.Message)" }
      if($res -and $res.Quota){
        $quotaStrikes[$ai]++
        $skip = [Math]::Min(48, [Math]::Pow(2, $quotaStrikes[$ai]))
        $quotaSkip[$ai] = [int]$skip
        Log "cycle $cycle $ai QUOTA strike $($quotaStrikes[$ai]) -> backing off $([int]$skip) cycles (~$([int]($skip*$IntervalSec/60))m)"
        break
      } else {
        $quotaStrikes[$ai] = 0
      }
      if($task -lt $MaxTasksPerCycle){
        $remaining = 0
        try { $remaining = Count-OpenOrders $ai } catch {}
        if($remaining -le 0){ break }   # nothing left to drain -> don't manufacture busywork
        Log "cycle $cycle -> $ai drain ($remaining open orders remain)"
      }
    }
  }
  Log "cycle $cycle END"
  if($MaxCycles -gt 0 -and $cycle -ge $MaxCycles){ Log "reached MaxCycles=$MaxCycles, stopping"; break }
  Start-Sleep -Seconds $IntervalSec
}
