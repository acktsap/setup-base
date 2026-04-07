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
# Also checks non-active panes in the same window:
#   If any background pane is waiting for input, appends ? to the output.
#
# Uses a state file to debounce working→done transitions (15s cooldown)

set -euo pipefail

PANE_ID="${1:-}"
[[ -z "$PANE_ID" ]] && exit 0

AI_PATTERN='claude|codex|gemini'
COOLDOWN=15  # seconds to hold "working" state before allowing "done"

# --- Helpers ---

# Check if a pane has an AI CLI tool (claude, codex, gemini) as a direct child process.
pane_has_ai() {
  local pid
  pid=$(tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null) || return 1
  [[ -z "$pid" ]] && return 1
  ps -eo pid,ppid,comm 2>/dev/null \
    | awk -v ppid="$pid" '$2 == ppid {print $3}' \
    | grep -qiE "$AI_PATTERN"
}

# Check if a pane is showing a permission/confirmation prompt (e.g. Yes/No, [Y/n]).
# Captures the last 15 non-empty lines and matches common interactive prompt patterns.
pane_is_waiting() {
  local content
  content=$(tmux capture-pane -t "$1" -p 2>/dev/null | grep -v '^$' | tail -15)
  [[ -z "$content" ]] && return 1
  echo "$content" | grep -qiE \
    '\. Yes$|\. No$|\(Y\)es|\(N\)o|\(A\)lways|\[Y/n\]|\[y/N\]|\(y/n\)|proceed\s*\?'
}

# --- Window ID & state file ---
WIN_ID=$(tmux display-message -p -t "$PANE_ID" '#{window_id}' 2>/dev/null) || exit 0
SERVER_PID=$(tmux display-message -p '#{pid}' 2>/dev/null) || exit 0
STATE_DIR="${TMPDIR:-/tmp}/tmux-ai-status"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SERVER_PID}_${PANE_ID}"

set_style() {
  tmux setw -t "$WIN_ID" window-status-style "$1" 2>/dev/null
}

unset_style() {
  tmux setw -t "$WIN_ID" -u window-status-style 2>/dev/null
}

# --- 1. Determine active pane status ---
# Classify the active (focused) pane into one of: waiting, working, idle, or "" (no AI).
# Detection order matters — check from most specific to least:
#   1. User input prompt (waiting)  — highest priority, needs immediate attention
#   2. Spinner / progress text (working) — AI is actively processing
#   3. Shell prompt visible (idle)  — AI finished, shell returned
#   4. Fallback (working)           — AI process exists but state unclear
ACTIVE_STATUS=""

if pane_has_ai "$PANE_ID"; then
  CONTENT=$(tmux capture-pane -t "$PANE_ID" -p 2>/dev/null)
  CONTENT=$(echo "$CONTENT" | grep -v '^$' | tail -15)

  if [[ -z "$CONTENT" ]]; then
    ACTIVE_STATUS="idle"
  # 1. Permission / confirmation prompt detected
  elif echo "$CONTENT" | grep -qiE \
    '\. Yes$|\. No$|\(Y\)es|\(N\)o|\(A\)lways|\[Y/n\]|\[y/N\]|\(y/n\)|proceed\s*\?'; then
    ACTIVE_STATUS="waiting"
    echo "?" > "$STATE_FILE"
  # 2. Spinner characters or progress indicators
  elif echo "$CONTENT" | grep -qE '(^[✻✢✽✳◐⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] .*…|Running…|Thinking…)'; then
    ACTIVE_STATUS="working"
    date +%s > "$STATE_FILE"
  # 3. Shell prompt visible — AI has finished; apply cooldown to avoid flicker
  elif echo "$CONTENT" | grep -qE '^\s*(❯|>|›|\$)\s*$'; then
    if [[ -f "$STATE_FILE" ]]; then
      LAST=$(cat "$STATE_FILE" 2>/dev/null)
      # If last state was "?" (input prompt), skip cooldown — transition immediately
      if [[ "$LAST" != "?" ]] && [[ "$LAST" =~ ^[0-9]+$ ]]; then
        NOW=$(date +%s)
        ELAPSED=$(( NOW - LAST ))
        if (( ELAPSED < COOLDOWN )); then
          ACTIVE_STATUS="working"
        else
          ACTIVE_STATUS="idle"
          rm -f "$STATE_FILE"
        fi
      else
        ACTIVE_STATUS="idle"
        rm -f "$STATE_FILE"
      fi
    else
      ACTIVE_STATUS="idle"
    fi
  # 4. Fallback: AI process exists but no recognized pattern — assume working
  else
    ACTIVE_STATUS="working"
    date +%s > "$STATE_FILE"
  fi
else
  # No AI process running in this pane
  rm -f "$STATE_FILE" 2>/dev/null
fi

# --- 2. Check non-active (background) panes for waiting ---
# Scan all other panes in the same window. If any background pane has an AI tool
# waiting for user input, flag it so we can surface it in the window status tab.
# Only the "waiting" state is checked — working/idle in background panes is ignored.
BG_WAITING=false
OTHER_PANES=$(tmux list-panes -t "$WIN_ID" -F '#{pane_id}' 2>/dev/null \
  | grep -v "^${PANE_ID}$" || true)

for pane in $OTHER_PANES; do
  if pane_has_ai "$pane" && pane_is_waiting "$pane"; then
    BG_WAITING=true
    break
  fi
done

# --- 3. Build output symbol and apply window tab color ---
# Combine active pane status with background waiting indicator.
# Examples:  "●"  = active working
#            "?"  = active waiting (or no active AI + bg waiting)
#            "●?" = active working + background pane waiting
#            "✓?" = active idle + background pane waiting
OUTPUT=""
case "$ACTIVE_STATUS" in
  waiting) OUTPUT="?" ;;
  working) OUTPUT="●" ;;
  idle)    OUTPUT="✓" ;;
esac

# Append "?" for background waiting, unless the active pane already shows "?"
if [[ "$BG_WAITING" == true && "$ACTIVE_STATUS" != "waiting" ]]; then
  OUTPUT="${OUTPUT:+$OUTPUT}?"
fi

# Color priority: yellow (needs attention) > green (working) > white (idle)
if [[ "$ACTIVE_STATUS" == "waiting" || "$BG_WAITING" == true ]]; then
  set_style "fg=yellow"
elif [[ "$ACTIVE_STATUS" == "working" ]]; then
  set_style "fg=green"
elif [[ "$ACTIVE_STATUS" == "idle" ]]; then
  set_style "fg=white"
else
  unset_style
fi

if [[ -n "$OUTPUT" ]]; then
  echo " $OUTPUT"
fi
