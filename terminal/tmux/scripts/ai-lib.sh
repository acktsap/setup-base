#!/usr/bin/env bash

AI_PATTERN="${AI_PATTERN:-claude|codex|gemini}"
CAPTURE_LINES="${CAPTURE_LINES:-30}"
STATE_TTL_SECONDS="${STATE_TTL_SECONDS:-90}"
STATE_DIR="${STATE_DIR:-${TMPDIR:-/tmp}/tmux-ai-status}"
RUNNING_PATTERN='(^[✻✢✽✳◐⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏] .*…|Running…|Thinking…|still thinking|thinking with|^[[:space:]]*• Working \()'

pane_recent_content() {
  tmux capture-pane -t "$1" -p 2>/dev/null \
    | grep -v '^[[:space:]]*$' \
    | tail -"$CAPTURE_LINES" || true
}

pane_has_ai() {
  local pid commands
  pid=$(tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null) || return 1
  [[ -z "$pid" ]] && return 1
  commands=$(ps -eo pid,ppid,comm 2>/dev/null | awk -v pid="$pid" '$1 == pid || $2 == pid {print $3}' || true)
  grep -qiE "$AI_PATTERN" <<< "$commands"
}

content_is_codex_waiting() {
  local lines last_line
  lines=$(printf '%s\n' "$1" | grep -v '^[[:space:]]*$' || true)
  [[ -z "$lines" ]] && return 1

  grep -qiE "Would you like to run the following command\?" <<< "$lines" || return 1
  grep -qE '^[^[:alnum:]]*[0-9]+\.[[:space:]]*(Yes, proceed|Yes, and don'\''t ask again|No, and tell Codex)' <<< "$lines" || return 1
  last_line=$(tail -1 <<< "$lines")
  grep -qiE "^[[:space:]]*Press enter to confirm or esc to cancel([[:space:]]+or[[:space:]]+.*)?$" <<< "$last_line"
}

content_is_claude_waiting() {
  local content="$1"
  local tail_lines
  tail_lines=$(printf '%s\n' "$content" | grep -v '^[[:space:]]*$' | tail -8 || true)
  if grep -qiE 'permission_prompt|Enter to select.*Esc to cancel' <<< "$tail_lines"; then
    return 0
  fi

  grep -qiE 'Do you want to proceed\?' <<< "$tail_lines" || return 1
  grep -qiE 'Esc to cancel' <<< "$tail_lines" || return 1
  grep -qE '^[^[:alnum:]]*[0-9]+\.[[:space:]]*Yes([[:space:]]|$)' <<< "$tail_lines" || return 1
  grep -qE '^[^[:alnum:]]*[0-9]+\.[[:space:]]*No([[:space:]]|$)' <<< "$tail_lines"
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

state_is_fresh() {
  local file="$1"
  local updated now
  [[ "$STATE_TTL_SECONDS" =~ ^[0-9]+$ ]] || STATE_TTL_SECONDS=90
  (( STATE_TTL_SECONDS <= 0 )) && return 0

  updated=$(state_value updated "$file")
  [[ "$updated" =~ ^[0-9]+$ ]] || return 1
  now=$(date +%s)
  (( now - updated <= STATE_TTL_SECONDS ))
}

fallback_status() {
  local content="$1"
  if [[ -z "$content" ]]; then
    printf 'idle\n'
  elif content_is_waiting "$content"; then
    printf 'waiting\n'
  elif grep -qiE "$RUNNING_PATTERN" <<< "$content"; then
    printf 'running\n'
  else
    printf 'idle\n'
  fi
}

status_for_pane() {
  local pane_id="$1"
  local content state_file status

  pane_has_ai "$pane_id" || return 1
  content=$(pane_recent_content "$pane_id")
  state_file=$(state_file_for_pane "$pane_id") || return 1
  status=$(state_value status "$state_file")

  if [[ "$status" == "waiting" ]]; then
    status=""
  fi
  if [[ -n "$content" ]] && content_is_waiting "$content"; then
    status="waiting"
  fi
  if [[ -n "$status" && "$status" != "waiting" ]] && ! state_is_fresh "$state_file"; then
    status=""
  fi
  if [[ -z "$status" ]]; then
    status=$(fallback_status "$content")
  fi

  printf '%s\n' "$status"
}

status_mark() {
  case "$1" in
    waiting) printf '?' ;;
    running) printf '●' ;;
    idle) printf '✓' ;;
    *) printf '' ;;
  esac
}
