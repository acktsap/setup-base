#!/usr/bin/env bash
# Show only windows whose current pane content is visibly waiting for input.

set -euo pipefail

CAPTURE_LINES=30

CURRENT_SESSION=$(tmux display-message -p '#{session_id}' 2>/dev/null) || exit 0

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
    | grep -qiE 'claude|codex|gemini'
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

window_label() {
  local target="$1"
  local index name
  index=$(tmux display-message -p -t "$target" '#{window_index}' 2>/dev/null) || return 1
  name=$(tmux display-message -p -t "$target" '#{window_name}' 2>/dev/null) || return 1
  printf '%s:%s' "$index" "$name"
}

remember_window() {
  local window="$1"
  local label="$2"
  local key="|$window|"
  [[ "$seen" == *"$key"* ]] && return 0
  seen="${seen}${window}|"
  labels="${labels}${label}"$'\n'
}

format_labels() {
  printf '%s' "$1" | awk 'NF { out = out (out ? ", " : "") $0 } END { printf "%s", out }'
}

seen="|"
labels=""

while IFS=' ' read -r pane session window; do
  [[ -n "$pane" && -n "$session" && -n "$window" ]] || continue
  [[ "$session" == "$CURRENT_SESSION" ]] || continue
  pane_has_ai "$pane" || continue

  content=$(pane_recent_content "$pane")
  [[ -n "$content" ]] || continue
  content_is_waiting "$content" || continue

  label=$(window_label "$window") || continue
  remember_window "$window" "$label"
done < <(tmux list-panes -a -F '#{pane_id} #{session_id} #{window_id}' 2>/dev/null)

[[ -n "$labels" ]] || exit 0
printf '#[fg=yellow]%s#[default]' "$(format_labels "$labels")"
