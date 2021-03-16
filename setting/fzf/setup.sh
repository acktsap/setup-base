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

readonly FZF_DARWIN_AMD64_URL=https://github.com/junegunn/fzf/releases/download/0.26.0/fzf-0.26.0-darwin_amd64.tar.gz

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$FZF_${ostype}_URL)

  if [[ $(check_bin_installed fzf) != "true" ]]; then
    download "${url}" /tmp/fzf.tar.gz
    extract /tmp/fzf.tar.gz "${INSTALL_PATH}/fzf"
    link "${INSTALL_PATH}/fzf/fzf" "${BIN_LINK_PATH}/fzf"
  fi
}

main "$@"