#!/usr/bin/env bash
# Show only windows whose current pane content is visibly waiting for input.

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null && pwd)"
. "$SCRIPT_DIR/ai-lib.sh"

current_session_id() {
  local session=""
  session=$(tmux display-message -p '#{session_id}' 2>/dev/null || true)
  if [[ -z "$session" && -n "${TMUX_PANE:-}" ]]; then
    session=$(tmux display-message -p -t "$TMUX_PANE" '#{session_id}' 2>/dev/null || true)
  fi
  printf '%s\n' "$session"
}

CURRENT_SESSION="${1:-}"
if [[ -z "$CURRENT_SESSION" ]]; then
  CURRENT_SESSION=$(current_session_id)
fi
[[ -n "$CURRENT_SESSION" ]] || exit 0

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
panes=$(tmux list-panes -s -t "$CURRENT_SESSION" -F '#{pane_id} #{session_id} #{window_id}' 2>/dev/null || true)

while IFS=' ' read -r pane session window; do
  [[ -n "$pane" && -n "$session" && -n "$window" ]] || continue
  [[ "$session" == "$CURRENT_SESSION" ]] || continue
  [[ "$(status_for_pane "$pane" 2>/dev/null || true)" == "waiting" ]] || continue

  label=$(window_label "$window") || continue
  remember_window "$window" "$label"
done <<< "$panes"

[[ -n "$labels" ]] || exit 0
printf '#[fg=yellow]%s#[default]' "$(format_labels "$labels")"
