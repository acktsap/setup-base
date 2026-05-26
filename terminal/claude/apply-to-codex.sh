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
  local codex_home="${HOME}/.agents"

  # Create ~/.agents if not exists
  if [[ ! -d "${codex_home}" ]]; then
    echo "-- Creating ${codex_home}"
    mkdir -p "${codex_home}"
  fi

  # Link skills individually
  if [[ -d "${SCRIPT_HOME}/skills" ]]; then
    if [[ ! -d "${codex_home}/skills" ]]; then
      echo "-- Creating ${codex_home}/skills"
      mkdir -p "${codex_home}/skills"
    fi
    for item in "${SCRIPT_HOME}/skills"/*; do
      local name=$(basename "${item}")
      link "${item}" "${codex_home}/skills/${name}"
    done
  fi

}

main "$@"
