#!/bin/bash -e

# Resolve script home
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_HOME/$SOURCE"
done
SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"


. $SCRIPT_HOME/../common

function main() {
  if [[ $(check_bin_runs bash-language-server --version) != "true" ]]; then
    install bash-language-server
  fi
  if [[ $(check_bin_runs bash-language-server --version) != "true" ]]; then
    echo "bash-language-server is installed but cannot run. Reinstall node and bash-language-server, then rerun setup."
    exit 1
  fi
}

main "$@"
