param(
  [int]$MaxCycles = 20,
  [int]$SleepSeconds = 600,
  [int]$InitialDelaySeconds = 0,
  [switch]$Once
)

$ErrorActionPreference = "Stop"

$Root = Split-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) -Parent
$Hub = Join-Path $Root "AI Infra\Communication"
$LogDir = Join-Path $Hub "agents\codex\logs"
$PidFile = Join-Path $LogDir "codex-loop.pid"
$StopFile = Join-Path $LogDir "codex-loop.stop"
$RunLog = Join-Path $LogDir "codex-loop.log"
$LastMessage = Join-Path $LogDir "codex-loop-last-message.md"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

function Stamp {
  Get-Date -Format "yyyy-MM-dd '/' HH:mm:ss"
}

function Write-LoopLog {
  param([string]$Message)
  Add-Content -LiteralPath $RunLog -Encoding utf8 -Value "[$(Stamp) KST] $Message"
}

if (Test-Path -LiteralPath $PidFile) {
  $existingText = (Get-Content -LiteralPath $PidFile -Raw).Trim()
  $existingPid = 0
  if ([int]::TryParse($existingText, [ref]$existingPid)) {
    $existing = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
    if ($existing) {
      Write-LoopLog "already running pid=$existingPid; exiting"
      exit 0
    }
  }
}

Set-Content -LiteralPath $PidFile -Encoding utf8 -Value $PID
Write-LoopLog "started pid=$PID maxCycles=$MaxCycles sleepSeconds=$SleepSeconds initialDelaySeconds=$InitialDelaySeconds once=$Once"

try {
  if ($InitialDelaySeconds -gt 0) {
    Write-LoopLog "initial delay start seconds=$InitialDelaySeconds"
    Start-Sleep -Seconds $InitialDelaySeconds
  }

  for ($cycle = 1; $cycle -le $MaxCycles; $cycle++) {
    if (Test-Path -LiteralPath $StopFile) {
      Write-LoopLog "stop file found; exiting"
      break
    }

    $controlPath = Join-Path $Hub "CONTROL.md"
    $control = if (Test-Path -LiteralPath $controlPath) { Get-Content -LiteralPath $controlPath -Raw } else { "" }
    $stateMatch = [regex]::Match($control, "(?m)^\s*state:\s*([A-Za-z_-]+)")
    $state = if ($stateMatch.Success) { $stateMatch.Groups[1].Value.ToLowerInvariant() } else { "running" }
    if ($state -ne "running") {
      Write-LoopLog "CONTROL state=$state; exiting before cycle=$cycle"
      break
    }

    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $promptFile = Join-Path $LogDir "codex-loop-prompt-$stamp.md"
    $jsonLog = Join-Path $LogDir "codex-loop-cycle-$stamp.jsonl"

    $prompt = @"
You are Codex in the 4-AI Communication Hub.

Run exactly one autonomous Codex loop iteration, then stop. Do not create, start, edit, or schedule another loop; this PowerShell wrapper owns the cadence.

Required operating rules:
- Respond in Korean.
- Read and obey $Root\AGENTS.md plus $Root\AI Infra\Communication\agents\codex\RULES.md.
- Re-ground on $Root\AI Infra\Communication\CONTROL.md, PROTOCOL.md sections 11, 12, 25, 26, 27, 31, 32, BOARD.md, DECISIONS.md, and your Codex inbox via tools\board.ps1 -Me codex.
- If CONTROL state is not running, write a short STATUS update only and stop.
- Prefer actionable to:codex requests. If none, choose the highest-value Codex-lane task: UI/UX, accessibility, visual consistency, i18n copy, or anti-slop.
- Work only in Codex-owned spaces. For 2nd-B code use $Root\_worktrees\2ndB-codex, never edit $Root\2ndB directly.
- Keep scope to one task. Run appropriate verification. Commit with Conventional Commits. You may push only your own branch, never main, and never create or merge PRs.
- Record every user-direct or autonomous task in the hub: agents/codex/STATUS.md, agents/codex/outbox/*.md, and a self-contained HTML summary under agents/codex/outbox/preview/.
- Commit hub changes with tools\commit.ps1 -As codex and only Codex-owned files.
- Use real KST timestamps from Get-Date; do not guess.
- If no safe task is available because of throttle, merge-wait, or missing context, write a heartbeat/status report instead of fabricating work.

This is cycle wakeup time: $(Stamp) KST.
"@

    Set-Content -LiteralPath $promptFile -Encoding utf8 -Value $prompt
    Write-LoopLog "cycle=$cycle start prompt=$promptFile json=$jsonLog"

    Push-Location $Root
    try {
      $oldErrorActionPreference = $ErrorActionPreference
      $ErrorActionPreference = "Continue"
      try {
        Get-Content -LiteralPath $promptFile -Raw |
          & codex -s danger-full-access -a never exec -C $Root --skip-git-repo-check --json -o $LastMessage - *>> $jsonLog
        $exitCode = $LASTEXITCODE
      } catch {
        $exitCode = 1
        Write-LoopLog "cycle=$cycle native command exception: $($_.Exception.Message)"
      } finally {
        $ErrorActionPreference = $oldErrorActionPreference
      }
    } finally {
      Pop-Location
    }

    Write-LoopLog "cycle=$cycle exit=$exitCode lastMessage=$LastMessage json=$jsonLog"

    if ($Once) {
      break
    }
    if ($cycle -lt $MaxCycles) {
      Start-Sleep -Seconds $SleepSeconds
    }
  }
} catch {
  Write-LoopLog "fatal: $($_.Exception.Message)"
  throw
} finally {
  $pidText = if (Test-Path -LiteralPath $PidFile) { (Get-Content -LiteralPath $PidFile -Raw).Trim() } else { "" }
  if ($pidText -eq [string]$PID) {
    Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
  }
  Write-LoopLog "stopped pid=$PID"
}
