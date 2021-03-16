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

readonly TIG_SRC_URL=https://github.com/jonas/tig/releases/download/tig-2.5.3/tig-2.5.3.tar.gz

function main() {
  local name=tig

  if [[ $(check_bin_installed tig) != "true" ]]; then
    download "${TIG_SRC_URL}" /tmp/tig.tar.gz
    extract /tmp/tig.tar.gz "${INSTALL_PATH}/tig"
    
    # https://jonas.github.io/tig/INSTALL.html
    # no readline
    echo "-- Installing.."
    pushd "${INSTALL_PATH}/tig/tig-2.5.3" > /dev/null
    ./configure > /dev/null
    make install prefix=. > /dev/null
    popd > /dev/null

    link "${INSTALL_PATH}/tig/tig-2.5.3/bin/tig" "${BIN_LINK_PATH}/tig"
  fi
}

main "$@"