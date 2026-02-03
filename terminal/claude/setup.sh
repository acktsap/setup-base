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
  local claude_home="${HOME}/.claude"

  # Create ~/.claude if not exists
  if [[ ! -d "${claude_home}" ]]; then
    mkdir -p "${claude_home}"
  fi

  # Link settings.json
  if [[ -f "${SCRIPT_HOME}/settings.json" ]]; then
    link "${SCRIPT_HOME}/settings.json" "${claude_home}/settings.json"
  fi

  # Link CLAUDE.md (user memory)
  if [[ -f "${SCRIPT_HOME}/CLAUDE.md" ]]; then
    link "${SCRIPT_HOME}/CLAUDE.md" "${claude_home}/CLAUDE.md"
  fi

  # Link rules directory
  if [[ -d "${SCRIPT_HOME}/rules" ]]; then
    link "${SCRIPT_HOME}/rules" "${claude_home}/rules"
  fi

  # Link skills directory
  if [[ -d "${SCRIPT_HOME}/skills" ]]; then
    link "${SCRIPT_HOME}/skills" "${claude_home}/skills"
  fi

  # Link agents directory
  if [[ -d "${SCRIPT_HOME}/agents" ]]; then
    link "${SCRIPT_HOME}/agents" "${claude_home}/agents"
  fi

}

main "$@"
