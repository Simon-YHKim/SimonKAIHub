# feed.ps1 -- chat-style LIVE view of the 4-AI hub "conversation".
# Reads it like a chat: who is working right now (live "typing" indicator), a
# chronological message timeline (each hub commit = a message from that AI), and
# the live output tail of whichever AI is currently working. Auto-refreshes.
# Complements monitor.ps1 (status dashboard); this one is the conversation.
#
#   powershell -ExecutionPolicy Bypass -File tools/feed.ps1
#   powershell -ExecutionPolicy Bypass -File tools/feed.ps1 -Interval 3
#   powershell -ExecutionPolicy Bypass -File tools/feed.ps1 -Once
param([int]$Interval = 5, [switch]$Once)
$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8
$root = Split-Path $PSScriptRoot -Parent
$colors = @{ claude='Cyan'; codex='Green'; grok='Magenta'; antigravity='Yellow'; 'AI Hub'='DarkGray' }
function ColorOf($name){ if($colors.ContainsKey($name)){ return $colors[$name] }; return 'White' }

# AIs whose hub-daemon.ps1 loop is actually ALIVE right now (process check).
function Get-LiveDaemonAIs {
  $ais = @()
  try {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
      Where-Object { $_.CommandLine -match 'hub-daemon\.ps1' } |
      ForEach-Object { if($_.CommandLine -match '-Only\s+(\w+)'){ $ais += $matches[1] } }
  } catch {}
  return @($ais | Select-Object -Unique)
}

# Which AIs are mid-cycle right now = daemon ALIVE *and* a poll with no matching exit after it.
# The live-daemon gate stops a daemon killed mid-cycle (dangling poll, no exit) from showing
# "working now" forever -- same false-positive the monitor had.
function Get-Working {
  $live = Get-LiveDaemonAIs
  $dlog = Join-Path $root "tools\hub-daemon.log"
  $res = @()
  if(Test-Path $dlog){
    $lines = @(Get-Content $dlog -Encoding UTF8 -Tail 80)
    foreach($ai in @('codex','grok','antigravity')){
      if($live -notcontains $ai){ continue }
      $lastPoll = -1; $lastExit = -1
      for($i=0;$i -lt $lines.Count;$i++){
        if($lines[$i] -match ("->\s+" + $ai + "\s+poll")){ $lastPoll = $i }
        if($lines[$i] -match ("exit\(" + $ai + "\)")){ $lastExit = $i }
      }
      if($lastPoll -ge 0 -and $lastPoll -gt $lastExit){ $res += $ai }
    }
  }
  return $res
}

function Render {
  $bar = ("=" * 78)
  Write-Host $bar -ForegroundColor DarkCyan
  Write-Host ("  AI HUB - LIVE CONVERSATION      {0} KST      (Ctrl+C to stop)" -f (Get-Date -Format 'HH:mm:ss')) -ForegroundColor DarkCyan
  Write-Host $bar -ForegroundColor DarkCyan

  $working = @(Get-Working)
  $liveDaemons = @(Get-LiveDaemonAIs)
  if($working.Count -gt 0){
    foreach($w in $working){ Write-Host ("  > {0} is working now..." -f $w) -ForegroundColor (ColorOf $w) }
  } elseif($liveDaemons.Count -eq 0){
    Write-Host "  (no daemons running - launch via HUB-STARTUP.html step 2)" -ForegroundColor DarkGray
  } else {
    Write-Host ("  (daemons idle between polls: " + ($liveDaemons -join ', ') + " @ 10min)") -ForegroundColor DarkGray
  }
  Write-Host ("-" * 78) -ForegroundColor DarkGray

  # Conversation timeline: hub commits as messages, oldest -> newest (chat order)
  $log = @(git -C $root log -16 --format='%cd|%an|%s' --date=format:'%H:%M' 2>$null)
  if($log.Count -gt 0){
    [array]::Reverse($log)
    foreach($l in $log){
      $p = $l.Split('|',3)
      if($p.Count -lt 3){ continue }
      $t = $p[0]; $who = $p[1]; $msg = $p[2]
      if($msg.Length -gt 58){ $msg = $msg.Substring(0,57) + "~" }
      Write-Host ("  {0} " -f $t) -ForegroundColor DarkGray -NoNewline
      Write-Host ("{0,-12}" -f $who) -ForegroundColor (ColorOf $who) -NoNewline
      Write-Host (" " + $msg) -ForegroundColor Gray
    }
  }
  Write-Host ("-" * 78) -ForegroundColor DarkGray

  # Current-activity pane: live transcript tail of the working AI (its "message being typed").
  $liveDir = Join-Path $root "tools\live"
  $focus = if($working.Count -gt 0){ $working[0] } else { $null }
  if($focus){
    $lf = Join-Path $liveDir ($focus + ".log")
    Write-Host ("[{0} - live output]" -f $focus) -ForegroundColor (ColorOf $focus)
    if(Test-Path $lf){
      Get-Content $lf -Encoding UTF8 -Tail 12 | ForEach-Object { Write-Host ("   " + $_) -ForegroundColor DarkGray }
    } else {
      Write-Host "   (transcript fills after this AI finishes its current cycle)" -ForegroundColor DarkGray
    }
  } else {
    Write-Host "[last thing each AI said]" -ForegroundColor DarkCyan
    foreach($ai in @('codex','grok','antigravity')){
      $lf = Join-Path $liveDir ($ai + ".log")
      if(Test-Path $lf){
        $body = @(Get-Content $lf -Encoding UTF8 | Where-Object { $_ -notmatch '^\[' -and $_.Trim() -ne "" })
        $last = if($body.Count -gt 0){ $body[-1] } else { "" }
        if($last.Length -gt 64){ $last = $last.Substring(0,63) + "~" }
        Write-Host ("  {0,-12}" -f $ai) -ForegroundColor (ColorOf $ai) -NoNewline
        Write-Host (" " + $last) -ForegroundColor DarkGray
      } else {
        Write-Host ("  {0,-12} (no transcript yet)" -f $ai) -ForegroundColor DarkGray
      }
    }
  }
}

if($Once){ Render; return }
try { while($true){ Clear-Host; Render; Start-Sleep -Seconds $Interval } }
catch [System.Management.Automation.PipelineStoppedException] { }
finally { Write-Host "`n[feed stopped]" -ForegroundColor DarkGray }
