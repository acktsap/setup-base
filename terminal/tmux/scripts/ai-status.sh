#!/usr/bin/env bash
# ai-status.sh - detect AI CLI tool status in a tmux pane
# Usage: ai-status.sh <pane_id>
#
# Outputs a short symbol and sets the window tab color:
#   (empty)        - no AI tool running
#   ?  (yellow)    - waiting for user input (permission/confirmation)
#   ●  (green)     - AI tool is working
#   ✓  (default)   - AI tool is idle (done)
#
# Uses a state file to debounce working→done transitions (15s cooldown)

set -euo pipefail

PANE_ID="${1:-}"
[[ -z "$PANE_ID" ]] && exit 0

# --- 1. Detect AI tool process ---
PANE_PID=$(tmux display-message -p -t "$PANE_ID" '#{pane_pid}' 2>/dev/null) || exit 0
[[ -z "$PANE_PID" ]] && exit 0

AI_PATTERN='claude|codex|gemini'
AI_PROC=$(ps -eo pid,ppid,comm 2>/dev/null \
  | awk -v ppid="$PANE_PID" '$2 == ppid {print $3}' \
  | grep -iE "$AI_PATTERN" \
  | head -1) || true

# --- 2. Get window ID for styling ---
WIN_ID=$(tmux display-message -p -t "$PANE_ID" '#{window_id}' 2>/dev/null) || exit 0

# --- 3. State file for debouncing (scoped by tmux server PID to avoid collisions) ---
SERVER_PID=$(tmux display-message -p '#{pid}' 2>/dev/null) || exit 0
STATE_DIR="${TMPDIR:-/tmp}/tmux-ai-status"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SERVER_PID}_${PANE_ID}"
COOLDOWN=15  # seconds to hold "working" state before allowing "done"

set_style() {
  tmux setw -t "$WIN_ID" window-status-style "$1" 2>/dev/null
}

unset_style() {
  tmux setw -t "$WIN_ID" -u window-status-style 2>/dev/null
}

if [[ -z "$AI_PROC" ]]; then
  unset_style
  rm -f "$STATE_FILE" 2>/dev/null
  exit 0
fi

# --- 4. Capture pane content ---
CONTENT=$(tmux capture-pane -t "$PANE_ID" -p 2>/dev/null)
CONTENT=$(echo "$CONTENT" | grep -v '^$' | tail -15)

if [[ -z "$CONTENT" ]]; then
  set_style "fg=white"
  echo " ✓"
  exit 0
fi

# --- 5. Determine state (order matters!) ---

# 5a. Waiting for user input?
if echo "$CONTENT" | grep -qiE \
  '\. Yes$|\. No$|\(Y\)es|\(N\)o|\(A\)lways|\[Y/n\]|\[y/N\]|\(y/n\)|proceed\s*\?'; then
  echo "?" > "$STATE_FILE"
  set_style "fg=yellow"
  echo " ?"
  exit 0
fi

# 5b. Working?
if echo "$CONTENT" | grep -qE '(^[✻✢✽✳◐⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] .*…|Running…|Thinking…)'; then
  date +%s > "$STATE_FILE"
  set_style "fg=green"
  echo " ●"
  exit 0
fi

# 5c. Idle?
if echo "$CONTENT" | grep -qE '^\s*(❯|>|›|\$)\s*$'; then
  # Check cooldown: if recently working, keep showing working
  if [[ -f "$STATE_FILE" ]]; then
    LAST=$(cat "$STATE_FILE" 2>/dev/null)
    # If last state was "?" (input prompt), allow immediate transition to done
    if [[ "$LAST" != "?" ]] && [[ "$LAST" =~ ^[0-9]+$ ]]; then
      NOW=$(date +%s)
      ELAPSED=$(( NOW - LAST ))
      if (( ELAPSED < COOLDOWN )); then
        set_style "fg=green"
        echo " ●"
        exit 0
      fi
    fi
    rm -f "$STATE_FILE"
  fi
  set_style "fg=white"
  echo " ✓"
  exit 0
fi

# 5d. Fallback: AI process exists, assume working
date +%s > "$STATE_FILE"
set_style "fg=green"
echo " ●"
