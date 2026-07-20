#!/bin/bash -e

SCRIPT_HOME="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

. "${SCRIPT_HOME}/../common"
. "${SCRIPT_HOME}/worktree-settings.sh"

function main() {
  mkdir -p "${HOME}/.orca"
  link "${SCRIPT_HOME}/keybindings.json" "${HOME}/.orca/keybindings.json"
  apply_orca_worktree_settings
}

main "$@"
