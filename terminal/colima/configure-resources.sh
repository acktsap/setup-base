#!/bin/bash -e

if [[ "$OSTYPE" != darwin* ]]; then
  echo "Skip Colima resource setup: macOS only"
  exit 0
fi

if ! command -v colima >/dev/null 2>&1; then
  echo "Colima must be installed first" >&2
  exit 1
fi

CONFIG_DIR="${HOME}/.colima/default"
CONFIG_FILE="${CONFIG_DIR}/colima.yaml"
mkdir -p "$CONFIG_DIR"

function config_value() {
  local key="$1"
  local fallback="$2"

  if [[ -f "$CONFIG_FILE" ]]; then
    local value
    value="$(awk -v key="$key" '$0 ~ "^" key ":[[:space:]]*" { sub("^[^:]*:[[:space:]]*", ""); sub(/[[:space:]]+#.*/, ""); print; exit }' "$CONFIG_FILE")"
    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return
    fi
  fi

  printf '%s' "$fallback"
}

function prompt_value() {
  local label="$1"
  local current="$2"
  local maximum="$3"
  local pattern="$4"
  local value

  while true; do
    read -r -p "$label (current: $current, max: $maximum): " value
    value="${value:-$current}"
    if [[ "$value" =~ $pattern ]]; then
      printf '%s' "$value"
      return
    fi
    echo "Enter a valid $label value" >&2
  done
}

max_cpu="$(sysctl -n hw.logicalcpu)"
max_memory="$(sysctl -n hw.memsize | awk '{ printf "%d GiB", $1 / 1024 / 1024 / 1024 }')"
max_disk="$(df -Pk "$CONFIG_DIR" | awk 'END { printf "%d GiB", $4 / 1024 / 1024 }')"

cpu="$(prompt_value CPU "$(config_value cpu 2)" "$max_cpu" '^[1-9][0-9]*$')"
memory="$(prompt_value 'Memory in GiB' "$(config_value memory 2)" "$max_memory" '^[1-9][0-9]*([.][0-9]+)?$')"
disk="$(prompt_value 'Disk in GiB' "$(config_value disk 100)" "$max_disk" '^[1-9][0-9]*$')"

temporary_file="$(mktemp "${CONFIG_DIR}/.colima.yaml.XXXXXX")"
trap 'rm -f "$temporary_file"' EXIT

if [[ -f "$CONFIG_FILE" ]]; then
  awk -v cpu="$cpu" -v memory="$memory" -v disk="$disk" '
    /^cpu:[[:space:]]*/ { print "cpu: " cpu; seen_cpu=1; next }
    /^memory:[[:space:]]*/ { print "memory: " memory; seen_memory=1; next }
    /^disk:[[:space:]]*/ { print "disk: " disk; seen_disk=1; next }
    { print }
    END {
      if (!seen_cpu) print "cpu: " cpu
      if (!seen_memory) print "memory: " memory
      if (!seen_disk) print "disk: " disk
    }
  ' "$CONFIG_FILE" > "$temporary_file"
else
  printf 'cpu: %s\nmemory: %s\ndisk: %s\n' "$cpu" "$memory" "$disk" > "$temporary_file"
fi

mv "$temporary_file" "$CONFIG_FILE"
trap - EXIT
echo "Updated Colima resources in $CONFIG_FILE"
