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

readonly GH_VERSION=2.87.3
readonly GH_DARWIN_AMD64_URL=https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_macOS_amd64.zip
readonly GH_DARWIN_ARM64_URL=https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_macOS_arm64.zip

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$GH_${ostype}_URL)

  if [[ $(check_bin_installed gh) != "true" ]]; then
    download "${url}" "$TMPDIR/gh.zip"
    extract "$TMPDIR/gh.zip" "$TMPDIR/gh"
    move "$TMPDIR/gh"/gh_*/bin/gh "${INSTALL_PATH}/gh/gh"
    link "${INSTALL_PATH}/gh/gh" "${BIN_LINK_PATH}/gh"
  fi
}

main "$@"
