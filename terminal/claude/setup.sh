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
    echo "-- Creating ${claude_home}"
    mkdir -p "${claude_home}"
  fi

  # Link settings.json
  # if [[ -f "${SCRIPT_HOME}/settings.json" ]]; then
  #   link "${SCRIPT_HOME}/settings.json" "${claude_home}/settings.json"
  # fi

  # Link rules individually
  if [[ -d "${SCRIPT_HOME}/rules" ]]; then
    if [[ ! -d "${claude_home}/rules" ]]; then
      echo "-- Creating ${claude_home}/rules"
      mkdir -p "${claude_home}/rules"
    fi
    for item in "${SCRIPT_HOME}/rules"/*; do
      local name=$(basename "${item}")
      link "${item}" "${claude_home}/rules/${name}"
    done
  fi

  # Link skills individually
  if [[ -d "${SCRIPT_HOME}/skills" ]]; then
    if [[ ! -d "${claude_home}/skills" ]]; then
      echo "-- Creating ${claude_home}/skills"
      mkdir -p "${claude_home}/skills"
    fi
    for item in "${SCRIPT_HOME}/skills"/*; do
      local name=$(basename "${item}")
      link "${item}" "${claude_home}/skills/${name}"
    done
  fi

  # Link agents individually
  if [[ -d "${SCRIPT_HOME}/agents" ]]; then
    if [[ ! -d "${claude_home}/agents" ]]; then
      echo "-- Creating ${claude_home}/agents"
      mkdir -p "${claude_home}/agents"
    fi
    for item in "${SCRIPT_HOME}/agents"/*; do
      local name=$(basename "${item}")
      link "${item}" "${claude_home}/agents/${name}"
    done
  fi

  # Append @import for CLAUDE.md
  if [[ -f "${SCRIPT_HOME}/CLAUDE.md" ]]; then
    local claude_md="${claude_home}/CLAUDE.md"
    local import_line="@${SCRIPT_HOME}/CLAUDE.md"
    if [[ ! -f "${claude_md}" ]]; then
      echo "-- Creating ${claude_md} with import"
      echo "${import_line}" > "${claude_md}"
    elif grep -qxF "${import_line}" "${claude_md}"; then
      echo "-- Skipping import (already present in ${claude_md})"
    else
      echo "-- Appending import to ${claude_md}"
      [[ -s "${claude_md}" && -n "$(tail -c 1 "${claude_md}")" ]] && echo "" >> "${claude_md}"
      echo "${import_line}" >> "${claude_md}"
    fi
  fi

}

main "$@"

echo "-- Applying to codex env.."
"${SCRIPT_HOME}/apply-to-codex.sh"
