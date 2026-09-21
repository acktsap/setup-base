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

JETBRAINS_CONFIG_HOME="${HOME}/Library/Application Support/JetBrains"
KEYMAP_FILE="acktsap_keymap.xml"

#######################################
# Turn off IntelliJ's "safe write", which saves to a temp file and renames it
# over the target. That rename replaces the keymap symlink with a plain file on
# the first settings change, cutting the link to this repo.
# Arguments:
#   1 ide.general.xml path (required)
#######################################
function disable_safe_write() {
  local options_file="${1:?options file is required}"

  if [[ ! -f "$options_file" ]]; then
    mkdir -p "$(dirname "$options_file")"
    cat > "$options_file" <<'EOF'
<application>
  <component name="GeneralSettings">
    <option name="isUseSafeWrite" value="false" />
  </component>
</application>
EOF
  elif grep -q 'name="isUseSafeWrite"' "$options_file"; then
    perl -0pi -e 's{<option name="isUseSafeWrite" value="[^"]*"\s*/>}{<option name="isUseSafeWrite" value="false" />}' "$options_file"
  elif grep -q '<component name="GeneralSettings">' "$options_file"; then
    perl -0pi -e 's{(<component name="GeneralSettings">)}{$1\n    <option name="isUseSafeWrite" value="false" />}' "$options_file"
  else
    perl -0pi -e 's{(<application>)}{$1\n  <component name="GeneralSettings">\n    <option name="isUseSafeWrite" value="false" />\n  </component>}' "$options_file"
  fi
}

function main() {
  if [[ "$OSTYPE" != darwin* ]]; then
    echo "  Only macOS config layout is supported, skipping"
    return
  fi

  if [[ ! -d "$JETBRAINS_CONFIG_HOME" ]]; then
    echo "  No JetBrains config in ${JETBRAINS_CONFIG_HOME}, skipping"
    return
  fi

  # A running IDE flushes its in-memory settings on exit and would undo both steps.
  # Skip rather than exit, so a sourced setup-all.sh run keeps going.
  if pgrep -f "IntelliJ IDEA" > /dev/null; then
    echo "  IntelliJ IDEA is running, quit it and rerun, skipping"
    return
  fi

  for config_dir in "$JETBRAINS_CONFIG_HOME"/IntelliJIdea* "$JETBRAINS_CONFIG_HOME"/IdeaIC*; do
    [[ -d "$config_dir" ]] || continue

    echo "-- $(basename "$config_dir")"
    disable_safe_write "${config_dir}/options/ide.general.xml"
    mkdir -p "${config_dir}/keymaps"
    link "${SCRIPT_HOME}/keymaps/${KEYMAP_FILE}" "${config_dir}/keymaps/${KEYMAP_FILE}"
  done
}

main "$@"
