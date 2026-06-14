# expo-smoke.ps1 -- Deterministic Android emulator / Expo health smoke (NO LLM required).
# The gemini "AG seat" is rate-limited (429) and unreliable for device QA, and real emulator
# proofing otherwise depends on the Antigravity IDE being driven by a human. This gives the hub
# a dependable, scriptable crash-detector any agent (or Claude) can run to answer "does the app
# crash on the emulator right now?" -- it scans adb logcat for app-level FATAL/ANR/JS errors.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File "tools/expo-smoke.ps1"
#   powershell -ExecutionPolicy Bypass -File "tools/expo-smoke.ps1" -Package com.anonymous.x2ndbrain -Lines 4000
#   powershell -ExecutionPolicy Bypass -File "tools/expo-smoke.ps1" -Report   # also write agents/claude/outbox HTML-free md
param(
  [string]$Package = "com.anonymous.x2ndbrain",
  [int]$Lines = 3000,
  [switch]$Report
)
$ErrorActionPreference = 'Continue'
$utf8 = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = $utf8; $OutputEncoding = $utf8
$root = Split-Path $PSScriptRoot -Parent
function Now { Get-Date -Format 'yyyy-MM-dd / HH:mm:ss' }

function Find-Adb {
  $c = Get-Command adb -ErrorAction SilentlyContinue
  if($c){ return $c.Source }
  foreach($p in @("$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe","$env:ANDROID_HOME\platform-tools\adb.exe")){
    if($p -and (Test-Path $p)){ return $p }
  }
  return $null
}

Write-Host ("[expo-smoke " + (Now) + " KST] target=" + $Package) -ForegroundColor Cyan

# 1. Emulator process up?
$emu = @(Get-Process -Name 'qemu-system-x86_64','emulator' -ErrorAction SilentlyContinue).Count
if($emu -le 0){
  Write-Host "RESULT: NO-EMULATOR (qemu/emulator not running). Start one: emulator -avd Pixel_9_Pro_XL" -ForegroundColor Yellow
  return
}
Write-Host "emulator: running" -ForegroundColor Green

# 2. adb + device
$adb = Find-Adb
if(-not $adb){ Write-Host "RESULT: NO-ADB (adb not found on PATH or SDK platform-tools)." -ForegroundColor Yellow; return }
$devs = & $adb devices 2>$null | Select-String -Pattern "device$" | ForEach-Object { ($_ -split "\s+")[0] }
if(-not $devs){ Write-Host "RESULT: NO-DEVICE (adb sees no online device)." -ForegroundColor Yellow; return }
Write-Host ("adb device: " + ($devs -join ',')) -ForegroundColor Green

# 3. Is the app installed / running?  ($appPid -- NOT $pid, which is a PowerShell automatic var)
$pkgInstalled = (& $adb shell pm list packages 2>$null | Select-String -SimpleMatch $Package)
$pidRaw = & $adb shell pidof $Package 2>$null
$appPid = if($pidRaw){ ("$pidRaw").Trim() } else { "" }
Write-Host ("app installed: " + $(if($pkgInstalled){"yes"}else{"NO"}) + "  running pid: " + $(if($appPid){$appPid}else{"(not running)"})) -ForegroundColor $(if($pkgInstalled){"Green"}else{"Yellow"})

# 4. Scan recent logcat for APP-LEVEL crashes only. Match ERROR-LEVEL crash signatures, not the
# normal AndroidRuntime lifecycle ("START RuntimeInit", "Shutting down VM") that uiautomator and
# every process emit -- the first draft over-matched those as false crashes.
$logcat = & $adb logcat -d -t $Lines 2>$null
# Real crash signatures: a Java fatal, an error-level AndroidRuntime stack, an ANR, or an RN/JS error.
# Error/fatal level only -- a W (warning) ReactNativeJS line (e.g. a handled "persona build
# failed: UnknownHostException" against a demo backend) is NOT a crash; keeping PASS trustworthy.
$crashPat = 'FATAL EXCEPTION|\bE AndroidRuntime|ANR in |\bE ReactNativeJS|Hermes.*(fatal|abort)|Unhandled (JS|Promise) (Rejection|Error)'
$appPat   = [regex]::Escape($Package)
$hits = @($logcat | Where-Object {
  ($_ -match $crashPat) -or ($_ -match $appPat -and $_ -match '\bE [A-Za-z]' -and $_ -match 'Error|Exception|crash|FATAL')
})
# Drop known-benign emulator noise.
$hits = @($hits | Where-Object { $_ -notmatch 'AGTM parsing failed|skia|StrictMode|Davey! duration|Choreographer|Shutting down VM|START com\.android|boot image|lock profiling' })

if($hits.Count -eq 0){
  Write-Host "RESULT: PASS -- no app-level FATAL/ANR/JS crash in last $Lines logcat lines." -ForegroundColor Green
  $verdict = "PASS"
} else {
  Write-Host ("RESULT: CRASH-SIGNALS ($($hits.Count)) -- app-level errors found:") -ForegroundColor Red
  $hits | Select-Object -First 20 | ForEach-Object { Write-Host ("  " + $_.Substring(0,[Math]::Min(160,$_.Length))) -ForegroundColor Red }
  $verdict = "CRASH($($hits.Count))"
}

if($Report){
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $out = Join-Path $root ("agents\claude\outbox\" + $stamp + "-expo-smoke-result.md")
  $body = @()
  $body += "# expo-smoke result $(Now) KST"
  $body += ""
  $body += "- target: $Package"
  $body += "- emulator: running / device: $($devs -join ',')"
  $body += "- app installed: $(if($pkgInstalled){'yes'}else{'no'}) / pid: $(if($appPid){$appPid}else{'n/a'})"
  $body += "- verdict: $verdict (scanned $Lines logcat lines)"
  if($hits.Count -gt 0){ $body += ""; $body += "## crash signals"; $hits | Select-Object -First 20 | ForEach-Object { $body += ("- " + $_.Trim()) } }
  [System.IO.File]::WriteAllLines($out, $body, $utf8)
  Write-Host ("report: " + $out) -ForegroundColor DarkCyan
}
