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

readonly DIRENV_DARWIN_AMD64_URL=https://github.com/direnv/direnv/releases/download/v2.32.0/direnv.darwin-amd64
readonly DIRENV_DARWIN_ARM64_URL=https://github.com/direnv/direnv/releases/download/v2.32.0/direnv.darwin-arm64

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$DIRENV_${ostype}_URL)

  if [[ $(check_bin_installed direnv) != "true" ]]; then
    download "${url}" $TMPDIR/direnv
    move $TMPDIR/direnv "${INSTALL_PATH}/direnv/direnv"
    chmod +x "${INSTALL_PATH}/direnv/direnv"
    link "${INSTALL_PATH}/direnv/direnv" "${BIN_LINK_PATH}/direnv"
  fi

  if [[ ! -f "${HOME}/.direnvrc" ]]; then
    link "${SCRIPT_HOME}/direnvrc" "${HOME}/.direnvrc"
  fi
}

main "$@"
