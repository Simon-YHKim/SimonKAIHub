# hub-daemon.ps1 -- Autonomous 4-AI hub driver (PROTOCOL section 12/19/35.4).
# Makes Codex/Grok (and optionally Antigravity) keep investigating on their own:
# each cycle it asks every AI to read its inbox + do the next task in its lane + commit.
# Freshness is REAL, not faked: each AI's tools/live/<ai>.log (real transcript+mtime) and its
# git author time drive the monitor. The daemon runs cycles only while CONTROL.state==running
# (section 13), and each CLI call is bounded by -PerAITimeoutSec so one hung CLI can't stall
# the whole sequential loop. Claude stays the merge gate; AIs never push 2nd-B (branch/outbox only).
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
  [int]$PerAITimeoutSec = 1200,    # hard ceiling per CLI call; a hung CLI is killed + skipped (P0: hung CLI stalled the whole sequential loop forever)
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
  # Shared append: open with FileShare.ReadWrite so monitor/feed/hub-health can read the
  # log WHILE we write it. Add-Content's default sharing locked readers out mid-append,
  # which is what crashed the dashboards ("file in use by another process"). Retry a few
  # times in case another daemon instance is appending the same instant.
  for($i=0;$i -lt 4;$i++){
    try {
      $fs = [System.IO.File]::Open($daemonLog, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
      try { $sw = New-Object System.IO.StreamWriter($fs, $utf8); $sw.WriteLine($line); $sw.Flush(); $sw.Close() }
      finally { $fs.Close() }
      break
    } catch { Start-Sleep -Milliseconds 50 }
  }
}

# ---- O-15 #1: single-instance guard per lane (-Only) -- prevents duplicate daemons.
# The 03:22+03:23 double-launch ran 2 daemons per AI -> cycle dup + git race. A named
# mutex per lane: if another daemon for this lane already holds it, this one exits.
$laneKey = if ($Only.Count) { ($Only | Sort-Object) -join '+' } else { 'default' }
try {
  $script:daemonMutex = New-Object System.Threading.Mutex($false, "Global\hubdaemon_$laneKey")
  $owns = $false
  try { $owns = $script:daemonMutex.WaitOne(0) }
  catch [System.Threading.AbandonedMutexException] { $owns = $true }  # prior daemon died -> we own it now
  if (-not $owns) {
    Log "DUP-GUARD: a hub-daemon for lane '$laneKey' is already running. Exiting duplicate (PID $PID)."
    exit 0
  }
} catch { Log "DUP-GUARD: mutex check failed ($($_.Exception.Message)); continuing." }

# ---- Best-model config (source of truth = tools/models.json, refreshed daily). ----
# Each AI must always run the highest-benchmark model + max reasoning effort.
# Falls back to safe inline defaults if the file is missing/unparseable, so the
# daemon never dies just because models.json is absent.
$modelsFile = Join-Path $PSScriptRoot "models.json"
$Models = $null
if(Test-Path $modelsFile){ try { $Models = Get-Content $modelsFile -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $Models = $null } }
function Get-ModelCfg([string]$ai,[string]$key,[string]$default){
  try { $v = $Models.$ai.$key; if($v){ return [string]$v } } catch {}
  return $default
}

# NOTE (P0 fix 2026-06-14): the old Set-Heartbeat rewrote each AI's STATUS.md to
# force `state: running` + a fresh `updated:` stamp every cycle. That FAKED freshness
# (STATUS looked fresh even when the CLI did nothing), VIOLATED single-writer (the daemon
# wrote another AI's file), and MASKED a paused hub (forced running over a paused state).
# Removed. Real freshness now comes from honest signals the monitor already reads:
#   - tools/live/<ai>.log  (real transcript + real mtime, written by Invoke-AI below)
#   - git last-commit-by-author  (Get-GitLastByAuthor in monitor.ps1)
# and the daemon only runs cycles while CONTROL.state == running (gate in the loop).

if($Only.Count -gt 0){ $AIs = $Only } else { $AIs = @('codex','grok'); if($IncludeAG){ $AIs += 'antigravity' } }

# Quota backoff state: when an AI's CLI returns a 429/quota-exhausted error (e.g. the gemini
# AG seat hits TerminalQuotaError with an 8h reset), stop hammering it every cycle. Each
# consecutive quota failure doubles the cycles skipped (cap 48 ~= 8h at 10min); a clean run
# resets it. Without this the AG daemon burned a spawn every 10min for 8h producing nothing.
$quotaSkip    = @{}   # ai -> cycles still to skip
$quotaStrikes = @{}   # ai -> consecutive quota failures
# Persistent NON-quota failure backoff: a misconfigured AI (bad model id, untrusted-folder
# refusal, missing/erroring CLI) exits non-zero EVERY cycle and would otherwise spin silently
# for hours producing nothing (the "fresh growing by hours" symptom). Back off + log LOUD.
$failSkip     = @{}   # ai -> cycles still to skip after repeated hard failures
$failStrikes  = @{}   # ai -> consecutive non-quota, non-zero exits
foreach($a in $AIs){ $quotaSkip[$a] = 0; $quotaStrikes[$a] = 0; $failSkip[$a] = 0; $failStrikes[$a] = 0 }

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
  # Resolve best model + max effort per AI from models.json (always-best, §MODELS.md) IN THE
  # PARENT (Get-ModelCfg reads $Models here), then pass the values into the job below.
  $cm = Get-ModelCfg 'codex' 'model' 'gpt-5.5'
  $ce = Get-ModelCfg 'codex' 'effort' 'xhigh'
  $gm = Get-ModelCfg 'grok' 'model' 'grok-4.3'
  $ge = Get-ModelCfg 'grok' 'effort' 'high'
  $am = Get-ModelCfg 'antigravity' 'model' 'gemini-3.1-pro-preview'

  # P0 timeout guard: run the CLI inside a background job bounded by Wait-Job -Timeout. A hung
  # CLI (codex stdin-EOF hang, network stall) previously blocked the whole sequential loop
  # forever; now it is killed after $PerAITimeoutSec and the loop continues.
  $sb = {
    param($ai,$root,$prompt,$cm,$ce,$gm,$ge,$am)
    $o = ""
    switch($ai){
      'codex'       { $o = ("" | codex exec -s danger-full-access --skip-git-repo-check -C $root -m $cm -c "model_reasoning_effort=$ce" $prompt) 2>&1 | Out-String }
      'grok'        { $env:GROK_MODEL = $gm; $env:GROK_REASONING_EFFORT = $ge; $o = (grok -m $gm -p $prompt) 2>&1 | Out-String }
      'antigravity' { $env:GEMINI_CLI_TRUST_WORKSPACE = 'true'; $o = (gemini -m $am -p $prompt -y) 2>&1 | Out-String }
    }
    [pscustomobject]@{ Out = $o; Code = $LASTEXITCODE }
  }
  $job = Start-Job -ScriptBlock $sb -ArgumentList $ai,$root,$prompt,$cm,$ce,$gm,$ge,$am
  $fin = Wait-Job $job -Timeout $PerAITimeoutSec
  if(-not $fin){
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -Force -ErrorAction SilentlyContinue
    Log "cycle TIMEOUT($ai) after ${PerAITimeoutSec}s -- killed CLI, continuing"
    try { [System.IO.File]::WriteAllText($live, "[$(Now) KST] $ai (TIMEOUT ${PerAITimeoutSec}s)`n", $utf8) } catch {}
    return [pscustomobject]@{ Code = -1; Quota = $false; TimedOut = $true }
  }
  $rcv = Receive-Job $job 2>&1
  Remove-Job $job -Force -ErrorAction SilentlyContinue
  # Job results are deserialized, so match by property name (not [pscustomobject] type).
  $obj  = $rcv | Where-Object { $_ -and ($_.PSObject.Properties.Name -contains 'Out') } | Select-Object -Last 1
  $out  = if($obj){ [string]$obj.Out } else { ($rcv | Out-String) }
  $code = if($obj){ [int]$obj.Code } else { 0 }
  # Detect quota/rate-limit exhaustion so the caller can back off instead of re-spawning.
  $quota = ($out -match 'QUOTA_EXHAUSTED|RESOURCE_EXHAUSTED|TerminalQuotaError|exhausted your capacity|"code":\s*429|429 ')
  Log "cycle exit($ai)=$code$(if($quota){' QUOTA'})"
  # Keep the last ~45 non-empty lines (the AI's closing summary = its "what I just did")
  # as a live transcript -- written UTF-8 (Korean-safe) so feed.ps1 can show it like a chat message.
  $tail = (($out -split "`r?`n") | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 45) -join "`n"
  try { [System.IO.File]::WriteAllText($live, "[$(Now) KST] $ai (exit $code$(if($quota){' QUOTA-EXHAUSTED'}))`n`n$tail`n", $utf8) } catch {}
  return [pscustomobject]@{ Code = $code; Quota = [bool]$quota; TimedOut = $false }
}

# CONTROL.md run-state (§13): the daemon must not spawn AIs while the hub is paused/draining.
function Get-ControlState {
  $cf = Join-Path $root "CONTROL.md"
  if(-not (Test-Path -LiteralPath $cf)){ return 'running' }   # no semaphore -> assume running
  $h = Get-Content -LiteralPath $cf -Encoding UTF8 -TotalCount 12
  foreach($l in $h){ if($l -match '^\s*state:\s*"?(\w+)'){ return $matches[1].ToLower() } }
  return 'running'
}

Log "hub-daemon START interval=${IntervalSec}s AIs=$($AIs -join ',') maxTasks=$MaxTasksPerCycle timeout=${PerAITimeoutSec}s maxCycles=$MaxCycles"
$cycle = 0
while($true){
  # CONTROL.state gate (§13): only spawn AIs while running. paused/draining -> skip this cycle
  # (no fake heartbeat, no new work) and re-check after the interval.
  $cs = Get-ControlState
  if($cs -ne 'running'){
    Log "cycle skipped -- CONTROL.state=$cs (waiting; resumes when running)"
    if($MaxCycles -gt 0){ break }
    Start-Sleep -Seconds $IntervalSec
    continue
  }
  $cycle++
  Log "cycle $cycle BEGIN"
  foreach($ai in $AIs){
    # Quota backoff: skip this AI while its backoff window is open (e.g. gemini 429 / 8h reset).
    if($quotaSkip[$ai] -gt 0){
      $quotaSkip[$ai]--
      Log "cycle $cycle -> $ai SKIP (quota backoff, $($quotaSkip[$ai]) cycles left)"
      continue
    }
    # Hard-failure backoff: stop hammering an AI that is failing every cycle (bad config).
    if($failSkip[$ai] -gt 0){
      $failSkip[$ai]--
      Log "cycle $cycle -> $ai SKIP (hard-failure backoff, $($failSkip[$ai]) cycles left -- fix models.json / CLI auth / trusted-folder then restart)"
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
      if($res -and $res.Quota){
        $quotaStrikes[$ai]++
        $skip = [Math]::Min(48, [Math]::Pow(2, $quotaStrikes[$ai]))
        $quotaSkip[$ai] = [int]$skip
        Log "cycle $cycle $ai QUOTA strike $($quotaStrikes[$ai]) -> backing off $([int]$skip) cycles (~$([int]($skip*$IntervalSec/60))m)"
        break
      } else {
        $quotaStrikes[$ai] = 0
        # Non-quota hard failure (bad model id, untrusted folder, missing/erroring CLI). After
        # 4 in a row, back off with a LOUD log instead of spinning silently for hours.
        if((-not $res) -or ($res.Code -ne 0)){
          $failStrikes[$ai]++
          if($failStrikes[$ai] -ge 4){
            $skip = [Math]::Min(36, [Math]::Pow(2, $failStrikes[$ai] - 3))
            $failSkip[$ai] = [int]$skip
            Log "cycle $cycle $ai HARD-FAIL x$($failStrikes[$ai]) (exit $(if($res){$res.Code}else{'spawn'})) -> backing off $([int]$skip) cycles. FIX CONFIG (models.json / CLI auth / GEMINI_CLI_TRUST_WORKSPACE) then restart daemon."
          } else {
            Log "cycle $cycle $ai fail strike $($failStrikes[$ai]) (exit $(if($res){$res.Code}else{'spawn'}))"
          }
          break
        } else {
          $failStrikes[$ai] = 0
        }
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
