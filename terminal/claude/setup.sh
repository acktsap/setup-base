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
      # An empty source dir leaves the glob unexpanded, and linking the literal
      # `*` creates a symlink named `*` pointing nowhere.
      [[ -e "${item}" ]] || continue
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
      [[ -e "${item}" ]] || continue
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
      [[ -e "${item}" ]] || continue
      local name=$(basename "${item}")
      link "${item}" "${claude_home}/agents/${name}"
    done
  fi

  # Append @import for shared agent guidance
  if [[ -f "${SCRIPT_HOME}/AGENTS.global.md" ]]; then
    local claude_md="${claude_home}/CLAUDE.md"
    local import_line="@${SCRIPT_HOME}/AGENTS.global.md"
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

  # Register this repo's permission list, and expose the applier at a fixed path
  # so other repos can run it without knowing where this one is checked out.
  mkdir -p "${claude_home}/permission-lists"
  link "${SCRIPT_HOME}/permissions.allow.txt" "${claude_home}/permission-lists/setup-base.allow.txt"
  link "${SCRIPT_HOME}/permissions.deny.txt" "${claude_home}/permission-lists/setup-base.deny.txt"
  link "${SCRIPT_HOME}/apply-permissions.sh" "${claude_home}/apply-permissions.sh"

  # Non-fatal: a missing jq shouldn't abort the rest of the setup.
  "${SCRIPT_HOME}/apply-permissions.sh" "${claude_home}/settings.json" \
    || echo "-- Skipping permissions"
}

main "$@"

echo "-- Applying to codex env.."
"${SCRIPT_HOME}/apply-to-codex.sh"
