# monitor.ps1 -- Live AI Hub dashboard for the user's VS Code terminal (read-only).
# Shows CONTROL run-state, each AI's STATUS (state / last activity / age), inbox &
# blocker counts, open consensus, and recent hub commits. Auto-refreshes so Simon can
# watch the headless 4-AI loops live. ASCII-only source (PS 5.1 no-BOM safe).
#
# Usage (in a VS Code terminal, cwd = hub root):
#   powershell -ExecutionPolicy Bypass -File "tools/monitor.ps1"          # live, 5s refresh
#   powershell -ExecutionPolicy Bypass -File "tools/monitor.ps1" -Interval 3
#   powershell -ExecutionPolicy Bypass -File "tools/monitor.ps1" -Once    # single render
param([int]$Interval = 5, [switch]$Once)

$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
$root   = Split-Path $PSScriptRoot -Parent
$agents = @("claude","codex","antigravity","grok")

function Get-Front([string[]]$lines,[string]$key){
  $pat = "^" + $key + ':\s*"?(.*?)"?\s*$'
  $m = $lines | Select-String -Pattern $pat | Select-Object -First 1
  if($m){ return $m.Matches[0].Groups[1].Value }
  return ""
}
function Get-Age([string]$stamp){
  $s = ($stamp -replace 'KST','' -replace '/','' -replace '\s+',' ').Trim()
  try {
    $t = [datetime]::Parse($s)
    $d = (Get-Date) - $t
    if($d.TotalMinutes -lt 1){ return ("{0:n0}s ago" -f $d.TotalSeconds) }
    if($d.TotalHours   -lt 1){ return ("{0:n0}m ago" -f $d.TotalMinutes) }
    if($d.TotalDays    -lt 1){ return ("{0:n0}h ago" -f $d.TotalHours) }
    return ("{0:n0}d ago" -f $d.TotalDays)
  } catch { return "?" }
}
function Get-AgeDays([string]$stamp){
  # Total days since stamp; 0 on parse failure so an unparseable stamp is not flagged stale.
  $s = ($stamp -replace 'KST','' -replace '/','' -replace '\s+',' ').Trim()
  try { return ((Get-Date) - [datetime]::Parse($s)).TotalDays } catch { return 0 }
}

function Render {
  $now = Get-Date -Format 'yyyy-MM-dd / HH:mm:ss'
  $bar = ("=" * 78)
  Write-Host $bar -ForegroundColor Cyan
  Write-Host ("  AI HUB MONITOR     {0} KST     refresh {1}s  (Ctrl+C to stop)" -f $now,$Interval) -ForegroundColor Cyan
  Write-Host $bar -ForegroundColor Cyan

  $control = Join-Path $root "CONTROL.md"
  $controlState = ""
  if(Test-Path $control){
    $ch = Get-Content $control -Encoding UTF8 -TotalCount 12
    $st = Get-Front $ch 'state'
    $controlState = $st
    $rs = Get-Front $ch 'pause_reason'
    $col = if($st -eq 'running'){'Green'}elseif($st -eq 'paused'){'Red'}else{'Yellow'}
    Write-Host ("RUN STATE: {0}" -f $st.ToUpper()) -ForegroundColor $col
    if($rs){ Write-Host ("  reason: {0}" -f $rs.Substring(0,[Math]::Min(68,$rs.Length))) -ForegroundColor DarkGray }
  }
  # Autonomous daemon heartbeat (tools/hub-daemon.log) -- is the poll loop alive + what is it doing now?
  $dlog = Join-Path $root "tools\hub-daemon.log"
  if(Test-Path $dlog){
    $dlast = Get-Content $dlog -Encoding UTF8 -Tail 1
    $dts = ""; if($dlast -match '^\[([^\]]+) KST\]'){ $dts = $matches[1] }
    $dage = if($dts){ Get-Age $dts } else { "?" }
    $dmsg = ($dlast -replace '^\[[^\]]*\]\s*','').Trim()
    $dcol = if($dage -match 's ago|m ago'){'Green'}else{'DarkGray'}
    Write-Host ("DAEMON  {0,-10}{1}" -f $dage,$dmsg) -ForegroundColor $dcol
  } else {
    Write-Host "DAEMON  (not running -- launch tools/hub-daemon.ps1)" -ForegroundColor DarkGray
  }
  # 2nd-B live app HEAD (the GitHub Pages live target)
  $appdir = "E:\2ndB"
  if(Test-Path $appdir){
    $ahead = git -C $appdir rev-parse --short HEAD 2>$null
    $asub  = git -C $appdir log -1 --format='%s' 2>$null
    if($ahead){ Write-Host ("2nd-B   {0,-10}{1}" -f $ahead,$(if($asub){$asub.Substring(0,[Math]::Min(56,$asub.Length))}else{""})) -ForegroundColor Cyan }
  }
  Write-Host ("-" * 78) -ForegroundColor DarkGray

  Write-Host ("{0,-12}{1,-11}{2,-11}{3}" -f "AI","state","updated","last activity") -ForegroundColor White
  foreach($a in $agents){
    $sf = Join-Path $root ("agents\" + $a + "\STATUS.md")
    $state = "-"; $age = "-"; $act = ""; $rawState = ""; $stale = $false; $noStamp = $false
    if(Test-Path $sf){
      $lines = Get-Content $sf -Encoding UTF8
      $head = $lines | Select-Object -First 8
      $rawState = Get-Front $head 'state'
      $state = $rawState; if(-not $state){ $state = "-" }
      if($state.Length -gt 8){ $state = $state.Substring(0,8) }
      $upd = Get-Front $head 'updated'
      # Effective activity = most recent of the frontmatter 'updated:' stamp and the file's
      # actual mtime. A STATUS rewritten without refreshing 'updated:' (or with no frontmatter
      # at all, e.g. a bare status file) still reflects REAL freshness instead of "-"/stale.
      $best = (Get-Item $sf).LastWriteTime
      if($upd){ try { $ut=[datetime]::Parse((($upd -replace 'KST','' -replace '/','' -replace '\s+',' ').Trim())); if($ut -gt $best){ $best=$ut } } catch {} }
      $d = (Get-Date) - $best
      if($d.TotalSeconds -lt 0){ $d = [TimeSpan]::Zero }   # clock-skew / slightly-future stamp -> treat as now
      if($d.TotalMinutes -lt 1){ $age = ("{0:n0}s ago" -f $d.TotalSeconds) }
      elseif($d.TotalHours -lt 1){ $age = ("{0:n0}m ago" -f $d.TotalMinutes) }
      elseif($d.TotalDays -lt 1){ $age = ("{0:n0}h ago" -f $d.TotalHours) }
      else { $age = ("{0:n0}d ago" -f $d.TotalDays) }
      $stale = ($d.TotalDays -gt 1)
      $noStamp = (-not $upd)
      $idx = -1
      for($i=0;$i -lt $lines.Count;$i++){ if($lines[$i] -match '^\[\d{4}-\d{2}-\d{2}'){ $idx = $i; break } }
      if($idx -ge 0){
        $act = ($lines[$idx] -replace '^\[[^\]]*\]\s*','').Trim()
        if(-not $act -and ($idx+1) -lt $lines.Count){ $act = $lines[$idx+1].Trim() }
      }
    }
    # Reconcile STATUS against the hub CONTROL semaphore. A STATUS that still says
    # running while CONTROL is paused (or has not been touched in >1 day) is stale,
    # not live -- never paint it as actively running.
    $runlike = ($rawState -match '^\s*running')
    if($runlike -and ($controlState -eq 'paused')){
      $state = "stale-run?"
    } elseif($runlike -and $stale){
      $state = "STALE"
    }
    if($act.Length -gt 42){ $act = $act.Substring(0,41) + "~" }
    $live = ($age -match 's ago|m ago') -and -not $stale
    $rowcol =
      if($state -eq 'stale-run?' -or $state -eq 'STALE'){'Yellow'}
      elseif($state -eq 'paused' -or $rawState -match '^\s*paused'){'DarkGray'}
      elseif($live -and ($controlState -ne 'paused')){'Green'}
      else{'Gray'}
    Write-Host ("{0,-12}{1,-11}{2,-11}{3}" -f $a,$state,$age,$act) -ForegroundColor $rowcol
  }
  Write-Host ("-" * 78) -ForegroundColor DarkGray

  $msgs = @()
  foreach($a in $agents){
    $obx = Join-Path $root ("agents\" + $a + "\outbox")
    if(Test-Path $obx){
      Get-ChildItem $obx -Filter *.md -File -ErrorAction SilentlyContinue | ForEach-Object {
        $h = Get-Content $_.FullName -Encoding UTF8 -TotalCount 15
        $fm = @{}
        foreach($l in $h){ if($l -match '^(from|to|type|ref|status|id|priority):\s*"?(.*?)"?\s*$'){ $fm[$matches[1]] = $matches[2] } }
        $subj = $_.BaseName -replace '^\d{8}-\d{6}-(to-[a-z]+-)?',''
        $msgs += [pscustomobject]@{ From=$fm.from; To=$fm.to; Type=$fm.type; Status=$fm.status; Ref=$fm.ref; Id=$fm.id; Pri=$fm.priority; Subj=$subj }
      }
    }
  }
  $answered = $msgs | Where-Object { $_.Type -eq 'response' -and $_.Ref } | Select-Object -ExpandProperty Ref
  $inboxStr = ($agents | ForEach-Object {
    $me = $_
    $n = ($msgs | Where-Object { ($_.To -eq $me -or $_.To -eq 'all') -and $_.Type -eq 'request' -and $_.Status -eq 'open' -and ($answered -notcontains $_.Id) }).Count
    ("{0}:{1}" -f $me.Substring(0,[Math]::Min(2,$me.Length)), $n)
  }) -join "  "
  $blk  = ($msgs | Where-Object { $_.Type -eq 'blocker' }).Count
  $cons = ($msgs | Where-Object { $_.Type -eq 'consensus_request' -and ($answered -notcontains $_.Id) }).Count
  Write-Host ("inbox  {0}    blockers:{1}    consensus open:{2}" -f $inboxStr,$blk,$cons) -ForegroundColor $(if($blk -gt 0){'Magenta'}else{'Gray'})
  # open requests detail (top 6) -- who owes what, at what priority
  $open = $msgs | Where-Object { $_.Type -eq 'request' -and $_.Status -eq 'open' -and ($answered -notcontains $_.Id) } | Select-Object -First 6
  foreach($o in $open){
    $os = if($o.Subj){ $o.Subj } else { "" }
    Write-Host ("   -> {0,-11}[{1,-4}] {2}" -f $o.To,$o.Pri,$os.Substring(0,[Math]::Min(46,$os.Length))) -ForegroundColor DarkCyan
  }
  # blocker detail
  $blocks = $msgs | Where-Object { $_.Type -eq 'blocker' } | Select-Object -First 4
  foreach($b in $blocks){
    $bs = if($b.Subj){ $b.Subj } else { "" }
    Write-Host ("   !! blocker <- {0}: {1}" -f $b.From,$bs.Substring(0,[Math]::Min(44,$bs.Length))) -ForegroundColor Magenta
  }
  Write-Host ("-" * 78) -ForegroundColor DarkGray

  Write-Host "recent hub commits:" -ForegroundColor DarkCyan
  $log = git -C $root log -8 --format='%cd|%an|%s' --date=format:'%m-%d %H:%M' 2>$null
  if($log){
    $log | ForEach-Object {
      $p = $_.Split('|',3)
      Write-Host ("  {0}  {1,-12} {2}" -f $p[0],$p[1],$p[2].Substring(0,[Math]::Min(48,$p[2].Length))) -ForegroundColor Gray
    }
  } else { Write-Host "  (no git log)" -ForegroundColor DarkGray }

  $prev = Get-ChildItem (Join-Path $root "agents") -Recurse -Filter *.html -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match 'outbox\\preview' } | Sort-Object LastWriteTime -Descending | Select-Object -First 3
  if($prev){
    Write-Host "`nrecent HTML reports:" -ForegroundColor DarkCyan
    $prev | ForEach-Object { Write-Host ("  {0}  {1}" -f $_.LastWriteTime.ToString('MM-dd HH:mm'),$_.Name) -ForegroundColor Gray }
  }
}

if($Once){ Render; return }
try {
  while($true){ Clear-Host; Render; Start-Sleep -Seconds $Interval }
} catch [System.Management.Automation.PipelineStoppedException] { }
finally { Write-Host "`n[monitor stopped]" -ForegroundColor DarkGray }
