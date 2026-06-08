#!/usr/bin/env bash
# ai-status.sh - detect AI CLI tool status in a tmux pane
# Usage: ai-status.sh <pane_id>
#
# Outputs a short symbol and sets the window tab color:
#   (empty)        - no AI tool running
#   ?  (yellow)    - waiting for user input (permission/confirmation)
#   ●  (cyan)      - AI tool is working
#   ✓  (green)     - AI tool is idle (done)
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
CAPTURE_LINES=30

# --- Helpers ---

pane_recent_content() {
  tmux capture-pane -t "$1" -p 2>/dev/null \
    | grep -v '^[[:space:]]*$' \
    | tail -"$CAPTURE_LINES" || true
}

# Check if a pane has an AI CLI tool (claude, codex, gemini) as a direct child process.
pane_has_ai() {
  local pid
  pid=$(tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null) || return 1
  [[ -z "$pid" ]] && return 1
  ps -eo pid,ppid,comm 2>/dev/null \
    | awk -v ppid="$pid" '$2 == ppid {print $3}' \
    | grep -qiE "$AI_PATTERN"
}

# Check Codex permission prompts.
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

# Check Claude-style permission/confirmation prompts (e.g. Yes/No, [Y/n]).
content_is_claude_waiting() {
  local content="$1"
  printf '%s\n' "$content" | grep -qiE \
    '\. Yes$|\. No$|\(Y\)es|\(N\)o|\(A\)lways|\[Y/n\]|\[y/N\]|\(y/n\)|proceed[[:space:]]*\?'
}

content_is_waiting() {
  local content="$1"
  content_is_codex_waiting "$content" || content_is_claude_waiting "$content"
}

# Check if a pane is showing a permission/confirmation prompt.
# Captures the most recent non-empty lines and matches per-tool prompt patterns.
pane_is_waiting() {
  local content
  content=$(pane_recent_content "$1")
  [[ -z "$content" ]] && return 1
  content_is_waiting "$content"
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
# Working requires an explicit progress signal (spinner + ellipsis). Anything else is
# idle, with a short cooldown to avoid flicker between spinner frames.
#   1. User input prompt (waiting)  — highest priority, needs immediate attention
#   2. Spinner / progress text (working) — AI is actively processing
#   3. Fallback (idle with cooldown) — AI process exists but no working signal
ACTIVE_STATUS=""

# Apply cooldown when no working signal is present.
# Returns "working" during cooldown window, "idle" otherwise.
idle_with_cooldown() {
  if [[ -f "$STATE_FILE" ]]; then
    local last
    last=$(cat "$STATE_FILE" 2>/dev/null)
    # If last state was "?" (input prompt), skip cooldown — transition immediately
    if [[ "$last" != "?" ]] && [[ "$last" =~ ^[0-9]+$ ]]; then
      local now elapsed
      now=$(date +%s)
      elapsed=$(( now - last ))
      if (( elapsed < COOLDOWN )); then
        echo "working"
        return
      fi
    fi
    rm -f "$STATE_FILE"
  fi
  echo "idle"
}

if pane_has_ai "$PANE_ID"; then
  CONTENT=$(pane_recent_content "$PANE_ID")

  if [[ -z "$CONTENT" ]]; then
    ACTIVE_STATUS="idle"
  # 1. Permission / confirmation prompt detected
  elif content_is_waiting "$CONTENT"; then
    ACTIVE_STATUS="waiting"
    echo "?" > "$STATE_FILE"
  # 2. Spinner characters or progress indicators
  elif echo "$CONTENT" | grep -qE '(^[✻✢✽✳◐⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] .*…|Running…|Thinking…|^[[:space:]]*• Working \()'; then
    ACTIVE_STATUS="working"
    date +%s > "$STATE_FILE"
  # 3. No working signal — idle (with cooldown to absorb spinner frame gaps)
  else
    ACTIVE_STATUS=$(idle_with_cooldown)
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

# Color priority: yellow (needs attention) > green (done) > cyan (working)
if [[ "$ACTIVE_STATUS" == "waiting" || "$BG_WAITING" == true ]]; then
  set_style "fg=yellow"
elif [[ "$ACTIVE_STATUS" == "idle" ]]; then
  set_style "fg=green"
elif [[ "$ACTIVE_STATUS" == "working" ]]; then
  set_style "fg=cyan"
else
  unset_style
fi

if [[ -n "$OUTPUT" ]]; then
  echo " $OUTPUT"
fi
