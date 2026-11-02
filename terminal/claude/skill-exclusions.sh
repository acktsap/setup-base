# Skills kept in this repo but not linked by setup.sh / apply-to-codex.sh.
# Link one on demand with link-skill.sh.
EXCLUDED_SKILLS=(
  write-london-unit-test
)

function is_excluded_skill() {
  local name="${1:?skill name is required}"
  local excluded
  # The `+` guard keeps an emptied list from tripping `set -u` on macOS bash 3.2.
  for excluded in ${EXCLUDED_SKILLS[@]+"${EXCLUDED_SKILLS[@]}"}; do
    [[ "${excluded}" == "${name}" ]] && return 0
  done
  return 1
}
