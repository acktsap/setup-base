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
  if [[ $(check_bin_installed lazygit) != "true" ]]; then
    install lazygit
  fi

  # config dir differs by OS (macOS uses ~/Library/Application Support); let lazygit resolve it.
  local config_dir="$(lazygit --print-config-dir)"
  mkdir -p "$config_dir"
  link "$SCRIPT_HOME/config.yml" "$config_dir/config.yml"
}

main "$@"
