#!/usr/bin/env bash
# Render one tmux pane's cached AI state as a compact status mark.

set -euo pipefail

PANE_ID="${1:-}"
[[ -z "$PANE_ID" ]] && exit 0

AI_PATTERN='claude|codex|gemini'
CAPTURE_LINES=30
STATE_DIR="${TMPDIR:-/tmp}/tmux-ai-status"

pane_recent_content() {
  tmux capture-pane -t "$1" -p 2>/dev/null \
    | grep -v '^[[:space:]]*$' \
    | tail -"$CAPTURE_LINES" || true
}

pane_has_ai() {
  local pid
  pid=$(tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null) || return 1
  [[ -z "$pid" ]] && return 1
  ps -eo pid,ppid,comm 2>/dev/null \
    | awk -v ppid="$pid" '$2 == ppid {print $3}' \
    | grep -qiE "$AI_PATTERN"
}

content_is_codex_waiting() {
  local lines
  lines=$(printf '%s\n' "$1" | grep -v '^[[:space:]]*$' || true)
  [[ -z "$lines" ]] && return 1

  printf '%s\n' "$lines" | grep -qiE \
    "Would you like to run the following command\?" || return 1
  printf '%s\n' "$lines" | grep -qE \
    '^[^[:alnum:]]*[0-9]+\.[[:space:]]*(Yes, proceed|Yes, and don'\''t ask again|No, and tell Codex)' || return 1
  printf '%s\n' "$lines" | tail -1 | grep -qiE \
    "^[[:space:]]*Press enter to confirm or esc to cancel$"
}

content_is_claude_waiting() {
  local content="$1"
  local tail_lines
  tail_lines=$(printf '%s\n' "$content" | grep -v '^[[:space:]]*$' | tail -8 || true)
  printf '%s\n' "$tail_lines" | grep -qiE \
    'permission_prompt|Enter to select.*Esc to cancel|\. Yes$|\. No$|\(Y\)es|\(N\)o|\(A\)lways|\[Y/n\]|\[y/N\]|\(y/n\)|proceed[[:space:]]*\?'
}

content_is_waiting() {
  local content="$1"
  content_is_codex_waiting "$content" || content_is_claude_waiting "$content"
}

state_file_for_pane() {
  local server_pid
  server_pid=$(tmux display-message -p '#{pid}' 2>/dev/null) || return 1
  printf '%s/%s_%s.state\n' "$STATE_DIR" "$server_pid" "$1"
}

state_value() {
  local key="$1"
  local file="$2"
  [[ -f "$file" ]] || return 0
  awk -F= -v key="$key" '$1 == key {sub(/^[^=]*=/, ""); print; exit}' "$file" 2>/dev/null
}

status_mark() {
  case "$1" in
    waiting) printf '?' ;;
    running) printf '●' ;;
    idle) printf '✓' ;;
    *) printf '' ;;
  esac
}

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

fallback_status() {
  local content="$1"
  if [[ -z "$content" ]]; then
    printf 'idle\n'
  elif content_is_waiting "$content"; then
    printf 'waiting\n'
  elif printf '%s\n' "$content" | grep -qiE '(^[✻✢✽✳◐⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] .*…|Running…|Thinking…|still thinking|thinking with|^[[:space:]]*• Working \()'; then
    printf 'running\n'
  else
    printf 'idle\n'
  fi
}

WIN_ID=$(tmux display-message -p -t "$PANE_ID" '#{window_id}' 2>/dev/null) || exit 0
STATE_FILE=$(state_file_for_pane "$PANE_ID") || exit 0

if ! pane_has_ai "$PANE_ID"; then
  rm -f "$STATE_FILE" 2>/dev/null
  set_window_style "$WIN_ID" ""
  exit 0
fi

CONTENT=$(pane_recent_content "$PANE_ID")
STATUS=$(state_value status "$STATE_FILE")

# Hook waiting events are only wake-up hints; a visible prompt is the source of truth for ?.
if [[ "$STATUS" == "waiting" ]]; then
  STATUS=""
fi
if [[ -n "$CONTENT" ]] && content_is_waiting "$CONTENT"; then
  STATUS="waiting"
fi

if [[ -z "$STATUS" ]]; then
  STATUS=$(fallback_status "$CONTENT")
fi

MARK=$(status_mark "$STATUS")
if [[ -z "$MARK" ]]; then
  set_window_style "$WIN_ID" ""
  exit 0
fi

set_window_style "$WIN_ID" "$STATUS"
printf '%s' "$MARK"
