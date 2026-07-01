#!/usr/bin/env bash
# Record Claude/Codex hook events for tmux status rendering.

set -euo pipefail

TOOL="${1:-}"
EVENT="${2:-}"
INPUT=$(cat 2>/dev/null || true)
STATE_DIR="${TMPDIR:-/tmp}/tmux-ai-status"

[[ -z "$TOOL" || -z "$EVENT" ]] && { printf '{}\n'; exit 0; }
[[ -z "${TMUX:-}" ]] && { printf '{}\n'; exit 0; }

PANE_ID="${TMUX_PANE:-}"
if [[ -z "$PANE_ID" ]]; then
  PANE_ID=$(tmux display-message -p '#{pane_id}' 2>/dev/null || true)
fi
[[ -z "$PANE_ID" ]] && { printf '{}\n'; exit 0; }

SERVER_PID=$(tmux display-message -p '#{pid}' 2>/dev/null || true)
WINDOW_ID=$(tmux display-message -p -t "$PANE_ID" '#{window_id}' 2>/dev/null || true)
[[ -z "$SERVER_PID" || -z "$WINDOW_ID" ]] && { printf '{}\n'; exit 0; }

case "$TOOL" in
  claude|codex|gemini) ;;
  *) TOOL="ai" ;;
esac

STATUS=""
SUMMARY=""
case "$EVENT" in
  session-start)
    STATUS="idle"
    SUMMARY="ready"
    ;;
  prompt-submit|pre-tool-use)
    STATUS="running"
    SUMMARY="thinking"
    ;;
  notification|notify)
    STATUS="waiting"
    SUMMARY="needs input"
    if printf '%s\n' "$INPUT" | grep -qi 'permission'; then
      SUMMARY="permission"
    fi
    ;;
  stop|session-end)
    STATUS="idle"
    SUMMARY="done"
    ;;
  *)
    STATUS="running"
    SUMMARY="$EVENT"
    ;;
esac

mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SERVER_PID}_${PANE_ID}.state"
TMP_FILE="${STATE_FILE}.$$"
NOW=$(date +%s)

# The state file is line-oriented so status scripts can parse it without sourcing
# data that originally came from hook stdin.
{
  printf 'pane=%s\n' "$PANE_ID"
  printf 'window=%s\n' "$WINDOW_ID"
  printf 'tool=%s\n' "$TOOL"
  printf 'status=%s\n' "$STATUS"
  printf 'summary=%s\n' "$SUMMARY"
  printf 'event=%s\n' "$EVENT"
  printf 'updated=%s\n' "$NOW"
} > "$TMP_FILE"
mv "$TMP_FILE" "$STATE_FILE"

tmux refresh-client -S 2>/dev/null || true
printf '{}\n'
