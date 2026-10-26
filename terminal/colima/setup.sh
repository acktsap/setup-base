#!/bin/bash -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_HOME/$SOURCE"
done
SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

. "$SCRIPT_HOME/../common"

function main() {
  if [[ "$OSTYPE" != darwin* ]]; then
    echo "Skip Colima setup: macOS only"
    return 0
  fi

  if [[ $(check_bin_installed colima) != "true" ]]; then
    install colima
  fi
}

main "$@"
