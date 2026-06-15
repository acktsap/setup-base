#!/usr/bin/env bash
# Start tmux only for the first Ghostty window.

set -euo pipefail

tmux_bin="${GHOSTTY_TMUX_BIN:-/usr/local/bin/tmux}"
tmux_session="${GHOSTTY_TMUX_SESSION:-main}"

ghostty_window_count() {
  case "$(uname)" in
    Darwin)
      macos_ghostty_window_count
      ;;
    *)
      printf '0\n'
      ;;
  esac
}

macos_ghostty_window_count() {
  if ! command -v osascript >/dev/null 2>&1; then
    printf '0\n'
    return
  fi

  osascript 2>/dev/null <<'APPLESCRIPT' || printf '0\n'
tell application "System Events"
  if exists process "Ghostty" then
    count of windows of process "Ghostty"
  else
    0
  end if
end tell
APPLESCRIPT
}

tmux_attached_client_count() {
  { "$tmux_bin" list-clients -t "$tmux_session" 2>/dev/null || true; } \
    | wc -l \
    | tr -d ' '
}

window_count="$(ghostty_window_count)"

if [[ "$window_count" =~ ^[0-9]+$ ]] && (( window_count > 1 )); then
  exec "${SHELL:-/bin/zsh}" -l
fi

client_count="$(tmux_attached_client_count)"

if [[ "$client_count" =~ ^[0-9]+$ ]] && (( client_count > 0 )); then
  exec "${SHELL:-/bin/zsh}" -l
fi

exec "$tmux_bin" new-session -A -s "$tmux_session"
