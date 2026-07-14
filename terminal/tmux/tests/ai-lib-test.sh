#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)"
. "$REPO_ROOT/scripts/ai-lib.sh"

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local name="$3"

  [[ "$actual" == "$expected" ]] || fail "$name: expected '$expected', got '$actual'"
}

run_test() {
  local name="$1"
  shift

  "$@" || fail "$name"
  printf 'ok - %s\n' "$name"
}

status_for_pane_should_report_waiting_for_claude_proceed_prompt() {
  local prompt result
  prompt='Bash command

   cd /tmp/example
   echo "$TOKEN"

 Contains expansion

 Do you want to proceed?
 > 1. Yes
   2. No

 Esc to cancel   Tab to amend   ctrl+e to explain'

  tmux() {
    case "$*" in
      "display-message -p -t %58 #{pane_pid}") printf '87224\n' ;;
      "capture-pane -t %58 -p") printf '%s\n' "$prompt" ;;
      "display-message -p #{pid}") printf '942\n' ;;
      *) return 1 ;;
    esac
  }

  ps() {
    case "$*" in
      "-eo pid,ppid,comm")
        printf '%s\n' \
          '  PID  PPID COMM' \
          '87224   942 -zsh' \
          '96978 87224 claude'
        ;;
      *) return 1 ;;
    esac
  }

  result=$(status_for_pane "%58")

  assert_eq "waiting" "$result" "${FUNCNAME[0]}"
}

run_test "status_for_pane reports waiting for Claude proceed prompt" \
  status_for_pane_should_report_waiting_for_claude_proceed_prompt
