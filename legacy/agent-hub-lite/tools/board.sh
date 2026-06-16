#!/usr/bin/env bash
# board.sh — show CONTROL state, your inbox, and recent activity.
# Usage: bash tools/board.sh [your-agent-name]
# "Inbox" is computed: open messages across all agents/*/outbox addressed to you (or all).
set -euo pipefail
ME="${1:-}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== CONTROL ==="
grep -E '^(state|reason):' CONTROL.md 2>/dev/null || echo "(no CONTROL.md)"

echo
echo "=== BOARD (in progress) ==="
sed -n '/## In progress/,/## Assigned/p' BOARD.md 2>/dev/null | sed '$d' || true

if [ -n "$ME" ]; then
  echo
  echo "=== INBOX for: $ME (open messages addressed to you or 'all') ==="
  found=0
  for f in agents/*/outbox/*.md; do
    [ -e "$f" ] || continue
    fm="$(sed -n '1,/^---$/p;/^---$/q' "$f")"  # frontmatter-ish
    to="$(grep -m1 -E '^to:' "$f" | sed 's/to:[[:space:]]*//')"
    st="$(grep -m1 -E '^status:' "$f" | sed 's/status:[[:space:]]*//')"
    if { [ "$to" = "$ME" ] || [ "$to" = "all" ]; } && [ "$st" = "open" ]; then
      from="$(grep -m1 -E '^from:' "$f" | sed 's/from:[[:space:]]*//')"
      typ="$(grep -m1 -E '^type:' "$f" | sed 's/type:[[:space:]]*//')"
      echo "  [$typ] from $from  ->  $f"
      found=1
    fi
  done
  [ "$found" = 0 ] && echo "  (empty)"
fi

echo
echo "=== Recent messages (last 8) ==="
ls -1t agents/*/outbox/*.md 2>/dev/null | head -8 | sed 's/^/  /' || echo "  (none)"
