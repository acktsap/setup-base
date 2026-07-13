#!/usr/bin/env bash
# Render one tmux pane's cached AI state as a compact status mark.

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null && pwd)"
. "$SCRIPT_DIR/ai-lib.sh"

PANE_ID="${1:-}"
[[ -z "$PANE_ID" ]] && exit 0

set_window_style() {
  local window_id="$1"
  local status="$2"

  case "$status" in
    waiting) tmux setw -t "$window_id" window-status-style "fg=yellow" 2>/dev/null ;;
    running) tmux setw -t "$window_id" window-status-style "fg=cyan" 2>/dev/null ;;
    idle) tmux setw -t "$window_id" window-status-style "fg=green" 2>/dev/null ;;
    *) tmux setw -t "$window_id" -u window-status-style 2>/dev/null ;;
  esac
}

WIN_ID=$(tmux display-message -p -t "$PANE_ID" '#{window_id}' 2>/dev/null) || exit 0
STATE_FILE=$(state_file_for_pane "$PANE_ID") || exit 0

STATUS=$(status_for_pane "$PANE_ID" || true)
if [[ -z "$STATUS" ]]; then
  rm -f "$STATE_FILE" 2>/dev/null
  set_window_style "$WIN_ID" ""
  exit 0
fi

MARK=$(status_mark "$STATUS")
if [[ -z "$MARK" ]]; then
  set_window_style "$WIN_ID" ""
  exit 0
fi

set_window_style "$WIN_ID" "$STATUS"
printf '%s' "$MARK"
