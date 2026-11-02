#!/usr/bin/env bash
set -euo pipefail

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


. "$SCRIPT_HOME/../common"

# Links skills into Claude Code and Codex, including ones in EXCLUDED_SKILLS.
# setup.sh skips excluded skills but leaves existing links alone, so a link made here survives a re-run.
function main() {
  if (( $# == 0 )); then
    echo "usage: $(basename "$0") <skill-name>..." >&2
    return 1
  fi

  local name
  for name in "$@"; do
    if [[ ! -d "${SCRIPT_HOME}/skills/${name}" ]]; then
      echo "no such skill: ${name}" >&2
      return 1
    fi
  done

  local home
  for home in "${HOME}/.claude" "${HOME}/.agents"; do
    mkdir -p "${home}/skills"
    for name in "$@"; do
      link "${SCRIPT_HOME}/skills/${name}" "${home}/skills/${name}"
    done
  done
}

main "$@"
