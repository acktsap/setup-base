#!/bin/bash -e

SCRIPT_HOME="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

. "${SCRIPT_HOME}/../common"

function main() {
  mkdir -p "${HOME}/.orca"
  link "${SCRIPT_HOME}/keybindings.json" "${HOME}/.orca/keybindings.json"
}

main "$@"
