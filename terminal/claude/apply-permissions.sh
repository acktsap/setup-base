#!/bin/bash -e

# Sets permissions.allow and permissions.deny in a Claude Code settings file from
# ~/.claude/permission-lists/*.allow.txt and *.deny.txt, and touches nothing else.
# Declarative: a line deleted from a list is removed from settings.json, so the
# lists are the source of truth and an entry added by hand does not survive.
#
# Usage: ./apply-permissions.sh [--dry-run] [settings.json]

LISTS="${HOME}/.claude/permission-lists"
BACKUP_KEEP=5

# Entry lines of one kind, deduplicated. `#` comments and blank lines dropped.
function lines() {
  cat "${LISTS}"/*."$1".txt 2>/dev/null \
    | sed -e 's/[[:space:]]*$//' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
    | awk '!seen[$0]++'
}

function main() {
  local dry_run=false settings="${HOME}/.claude/settings.json"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) dry_run=true ;;
      -h|--help) sed -n '3,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
      -*) echo "-- Unknown option: $1"; exit 1 ;;
      *) settings="$1" ;;
    esac
    shift
  done

  command -v jq >/dev/null || { echo "-- jq is required"; exit 1; }

  local allow_lines deny_lines
  allow_lines="$(lines allow)"
  deny_lines="$(lines deny)"

  # Claude Code skips a rule whose Tool(...) wrapper holds an unescaped paren.
  # For a deny rule that fails open, so refuse to write instead of warning.
  local bad
  bad="$(printf '%s\n%s\n' "${allow_lines}" "${deny_lines}" | sed '/^$/d' \
    | grep -vE '^[A-Za-z]+(\((\\[()]|[^()])*\))?$' || true)"
  if [[ -n "${bad}" ]]; then
    echo "-- Unescaped parentheses, escape as \\( and \\):"
    sed 's/^/     /' <<<"${bad}"
    exit 1
  fi

  local allow deny
  allow="$(jq -Rs 'split("\n") | map(select(length > 0))' <<<"${allow_lines}")"
  deny="$(jq -Rs 'split("\n") | map(select(length > 0))' <<<"${deny_lines}")"

  # No allow entries means the lists are missing, not that everything was
  # revoked. An empty deny list is a legitimate state.
  if [[ "$(jq length <<<"${allow}")" == 0 ]]; then
    echo "-- No entries in ${LISTS}/*.allow.txt, refusing to clear the allow list"
    exit 1
  fi

  local current='{"$schema": "https://json.schemastore.org/claude-code-settings.json"}'
  [[ -f "${settings}" ]] && current="$(< "${settings}")"

  local changes
  changes="$(jq -r --argjson a "${allow}" --argjson d "${deny}" '
    (.permissions.allow // []) as $oa | (.permissions.deny // []) as $od
    | (($a - $oa) | map("  + " + .)) + (($oa - $a) | map("  - " + .))
      + (($d - $od) | map("  + deny " + .)) + (($od - $d) | map("  - deny " + .))
    | .[]' <<<"${current}")"

  if [[ -z "${changes}" ]]; then
    echo "-- Already matches: $(jq length <<<"${allow}") allow, $(jq length <<<"${deny}") deny"
    exit 0
  fi
  echo "${changes}"

  if [[ "${dry_run}" == true ]]; then
    echo "-- Dry run, nothing written"
    exit 0
  fi

  # This run can remove entries, so back up first. $$ separates concurrent runs.
  if [[ -f "${settings}" ]]; then
    local backup="${settings}.bak.$(date +%Y%m%d%H%M%S)-$$"
    echo "-- Backing up to ${backup}"
    cp "${settings}" "${backup}"
  else
    mkdir -p "$(dirname "${settings}")"
  fi

  local tmp
  tmp="$(mktemp "${settings}.tmp.XXXXXX")"
  jq --argjson a "${allow}" --argjson d "${deny}" '
    .permissions = ((.permissions // {}) | .allow = $a
      | if ($d | length) > 0 then .deny = $d else del(.deny) end)
  ' <<<"${current}" > "${tmp}"
  mv "${tmp}" "${settings}"

  ls -1dt "${settings}".bak.* 2>/dev/null | tail -n "+$(( BACKUP_KEEP + 1 ))" \
    | while IFS= read -r old; do rm -f "${old}"; done

  echo "-- Done: $(jq length <<<"${allow}") allow, $(jq length <<<"${deny}") deny"
}

main "$@"
