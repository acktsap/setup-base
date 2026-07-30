#!/bin/bash -e

# Merge read-only permissions into Claude Code's allow list.
#
# Usage: ./allow-read-permissions.sh [--dry-run] [settings.json]

# Only commands outside Claude Code's built-in read-only set are listed. That
# set already runs without a prompt in every mode and is not configurable:
# ls, cat, echo, pwd, head, tail, grep, find, wc, which, diff, stat, du, cd,
# and read-only forms of git. Adding those here would be dead weight.
#
# Entries are matched as command prefixes, so subcommand-scoped entries
# (`gh pr view` rather than `gh`) are what keep the mutating variants out.
READ_PERMISSIONS=(
  # Tools. Read/Glob/Grep never prompt inside the working directory, but do
  # for paths outside it, which is what `Read(//**)` covers.
  "Read(//**)"
  "Glob"
  "Grep"
  "WebFetch"
  "WebSearch"

  # Files and directories
  "Bash(tree:*)"
  "Bash(file:*)"
  "Bash(df:*)"
  "Bash(realpath:*)"
  "Bash(basename:*)"
  "Bash(dirname:*)"
  "Bash(readlink:*)"

  # Content. `sort` is excluded because `-o` writes to a file.
  "Bash(nl:*)"
  "Bash(uniq:*)"
  "Bash(cut:*)"
  "Bash(tr:*)"
  "Bash(column:*)"
  "Bash(cmp:*)"
  "Bash(comm:*)"
  "Bash(jq:*)"

  # Search
  "Bash(rg:*)"
  "Bash(fd:*)"

  # Environment
  "Bash(type:*)"
  "Bash(command -v:*)"
  "Bash(env:*)"
  "Bash(printenv:*)"
  "Bash(uname:*)"
  "Bash(hostname:*)"
  "Bash(whoami:*)"
  "Bash(date:*)"
  "Bash(ps:*)"
  "Bash(lsof:*)"
  "Bash(bash -n:*)"
  "Bash(javap:*)"
  "Bash(helm template:*)"
  "Bash(helm version:*)"

  # Network lookups
  "Bash(host:*)"
  "Bash(dig:*)"
  "Bash(nslookup:*)"
  "Bash(nc -z:*)"
)

# `gh api` is excluded because it can issue writes via -X/-f.
GH_READ_SUBCOMMANDS=(
  "pr view"
  "pr list"
  "pr diff"
  "pr checks"
  "issue view"
  "issue list"
  "repo view"
  "run list"
  "run view"
  "workflow list"
  "search"
  "auth status"
)

for subcommand in "${GH_READ_SUBCOMMANDS[@]}"; do
  # An allow rule never matches past a leading assignment of a variable Claude
  # Code doesn't consider known-safe, so `gh pr view` alone leaves
  # `GH_HOST=<host> gh pr view` prompting. The wildcard grants the prefixed
  # form for any host without naming one. `:*` is only recognized at the end of
  # a pattern, so the trailing wildcard is written as ` *` here.
  READ_PERMISSIONS+=(
    "Bash(gh ${subcommand} *)"
    "Bash(GH_HOST=* gh ${subcommand} *)"
  )
done

function usage() {
  cat <<'EOF'
Usage: allow-read-permissions.sh [--dry-run] [settings.json]

Merges a curated set of read-only tool and Bash permissions into the
permissions.allow array of a Claude Code settings file.

  --dry-run   Print what would be added without writing.
  settings    Target settings file (default: ~/.claude/settings.json).
EOF
}

function main() {
  local dry_run=false
  local settings="${HOME}/.claude/settings.json"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) dry_run=true; shift ;;
      -h|--help) usage; exit 0 ;;
      -*) echo "-- Unknown option: $1"; usage; exit 1 ;;
      *) settings="$1"; shift ;;
    esac
  done

  if [[ $(command -v jq) == "" ]]; then
    echo "-- jq is required"
    exit 1
  fi

  local current
  if [[ -f "${settings}" ]]; then
    current="$(< "${settings}")"
  else
    echo "-- ${settings} not found, starting from an empty settings file"
    current='{"$schema": "https://json.schemastore.org/claude-code-settings.json"}'
  fi

  local additions
  additions="$(printf '%s\n' "${READ_PERMISSIONS[@]}" \
    | jq -Rs 'split("\n") | map(select(length > 0))')"

  local missing
  missing="$(jq -r --argjson add "${additions}" \
    '($add - (.permissions.allow // []))[]' <<<"${current}")"

  if [[ -z "${missing}" ]]; then
    echo "-- Already up to date: ${settings}"
    exit 0
  fi

  echo "-- Adding $(wc -l <<<"${missing}" | tr -d ' ') permission(s) to ${settings}"
  sed 's/^/     /' <<<"${missing}"

  if [[ "${dry_run}" == true ]]; then
    echo "-- Dry run, nothing written"
    exit 0
  fi

  local updated
  updated="$(jq --argjson add "${additions}" '
    def dedupe: reduce .[] as $item ([]; if index($item) then . else . + [$item] end);
    .permissions = ((.permissions // {}) | .allow = (((.allow // []) + $add) | dedupe))
  ' <<<"${current}")"

  if [[ -f "${settings}" ]]; then
    local backup="${settings}.bak.$(date +%Y%m%d%H%M%S)"
    echo "-- Backing up to ${backup}"
    cp "${settings}" "${backup}"
  else
    mkdir -p "$(dirname "${settings}")"
  fi

  printf '%s\n' "${updated}" > "${settings}"
  echo "-- Done"
}

main "$@"
