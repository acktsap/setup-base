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

# FIXME download from url
# readonly DIRENV_DARWIN_AMD64_URL=https://github.com/direnv/direnv/releases/download/v2.28.0/direnv.darwin-amd64

function main() {
  if [[ $(check_bin_installed broot) != "true" ]]; then
    install broot
    mkdir -p ${HOME}/.config/broot/
    link "$SCRIPT_HOME/conf.hjson" "$HOME/.config/broot/conf.hjson"
  fi
}

main "$@"
