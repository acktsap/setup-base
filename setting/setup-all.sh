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


. $SCRIPT_HOME/common

function main() {
  readonly local directories=$(find * -type d)

  echo "Install path: $INSTALL_PATH"

  create_dir "$INSTALL_PATH"
  create_dir "$LIB_LINK_PATH"
  create_dir "$BIN_LINK_PATH"

  for target in ${directories[@]}; do
    if [ -e ${target}/setup.sh ]; then
      echo "Setup ${target}.."
      . ${target}/setup.sh
    fi
  done
}

main "$@"
