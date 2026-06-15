#!/usr/bin/env bash
# Patch tmux-resurrect save files so AI CLIs restart by resuming sessions.

set -euo pipefail

RESURRECT_FILE="${1:-}"
[[ -z "$RESURRECT_FILE" || ! -f "$RESURRECT_FILE" ]] && exit 0

delimiter=$'\t'

file_mtime() {
  local file="$1"
  local mtime
  if mtime=$(stat -f %m "$file" 2>/dev/null) && [[ "$mtime" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$mtime"
  else
    stat -c %Y "$file"
  fi
}

json_field() {
  local filter="$1"
  jq -er "$filter" 2>/dev/null || true
}

codex_session_id_from_command() {
  awk '
    {
      for (i = 1; i <= NF; i++) {
        if ($i == "resume") {
          id = $(i + 1)
          if (id != "" && id !~ /^-/) {
            print id
            exit
          }
        }
      }
    }
  ' <<< "$1"
}

claude_session_id_from_command() {
  awk '
    {
      for (i = 1; i <= NF; i++) {
        if ($i == "--resume" || $i == "-r" || $i == "--session-id") {
          id = $(i + 1)
          if (id != "" && id !~ /^-/) {
            print id
            exit
          }
        }
      }
    }
  ' <<< "$1"
}

codex_session_id_for_cwd() {
  local cwd="$1"
  local sessions_dir="${CODEX_HOME:-$HOME/.codex}/sessions"
  local newest_mtime=0
  local newest_id=""

  command -v jq >/dev/null 2>&1 || return 1
  [[ -d "$sessions_dir" ]] || return 1

  while IFS= read -r -d '' file; do
    local meta file_cwd session_id mtime
    meta=$(head -n 1 "$file" 2>/dev/null || true)
    [[ -n "$meta" ]] || continue

    file_cwd=$(printf '%s' "$meta" | json_field '.payload.cwd // empty')
    [[ "$file_cwd" == "$cwd" ]] || continue

    session_id=$(printf '%s' "$meta" | json_field '.payload.id // empty')
    [[ -n "$session_id" ]] || continue

    mtime=$(file_mtime "$file")
    if (( mtime > newest_mtime )); then
      newest_mtime="$mtime"
      newest_id="$session_id"
    fi
  done < <(find "$sessions_dir" -type f -name '*.jsonl' -print0 2>/dev/null)

  [[ -n "$newest_id" ]] || return 1
  printf '%s\n' "$newest_id"
}

claude_project_dir_for_cwd() {
  local cwd="$1"
  local encoded
  encoded=$(printf '%s' "$cwd" | sed 's#/#-#g')
  printf '%s\n' "${CLAUDE_HOME:-$HOME/.claude}/projects/${encoded}"
}

claude_session_id_for_cwd() {
  local cwd="$1"
  local project_dir
  local newest_mtime=0
  local newest_id=""

  project_dir=$(claude_project_dir_for_cwd "$cwd")
  [[ -d "$project_dir" ]] || return 1

  while IFS= read -r -d '' file; do
    local session_id mtime
    session_id=$(basename "$file" .jsonl)
    [[ -n "$session_id" ]] || continue

    mtime=$(file_mtime "$file")
    if (( mtime > newest_mtime )); then
      newest_mtime="$mtime"
      newest_id="$session_id"
    fi
  done < <(find "$project_dir" -maxdepth 1 -type f -name '*.jsonl' -print0 2>/dev/null)

  [[ -n "$newest_id" ]] || return 1
  printf '%s\n' "$newest_id"
}

restore_command_for_pane() {
  local cwd="$1"
  local pane_command="$2"
  local full_command="$3"

  case "$pane_command $full_command" in
    *codex*|*Codex.app*)
      local codex_id
      if codex_id=$(codex_session_id_from_command "$full_command") && [[ -n "$codex_id" ]]; then
        printf 'codex resume %s\n' "$codex_id"
      elif codex_id=$(codex_session_id_for_cwd "$cwd"); then
        printf 'codex resume %s\n' "$codex_id"
      else
        printf 'codex resume --last\n'
      fi
      ;;
    *claude*)
      local claude_id
      if claude_id=$(claude_session_id_from_command "$full_command") && [[ -n "$claude_id" ]]; then
        printf 'claude --resume %s\n' "$claude_id"
      elif claude_id=$(claude_session_id_for_cwd "$cwd"); then
        printf 'claude --resume %s\n' "$claude_id"
      else
        printf 'claude --continue\n'
      fi
      ;;
    *gemini*)
      # Gemini CLI session persistence varies by version; restarting the CLI is
      # safer than inventing unsupported resume flags.
      printf 'gemini\n'
      ;;
  esac
}

patch_resurrect_file() {
  local tmp_file="${RESURRECT_FILE}.ai-resurrect.$$"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == pane"$delimiter"* ]]; then
      local line_type session_name window_number window_active window_flags pane_index
      local pane_title dir pane_active pane_command pane_full_command cwd full_command
      local restore_command

      IFS="$delimiter" read -r \
        line_type session_name window_number window_active window_flags pane_index \
        pane_title dir pane_active pane_command pane_full_command <<< "$line"

      cwd="${dir#:}"
      cwd="${cwd//\\ / }"
      full_command="${pane_full_command#:}"
      restore_command=$(restore_command_for_pane "$cwd" "$pane_command" "$full_command" || true)

      if [[ -n "$restore_command" ]]; then
        pane_full_command=":${restore_command}"
        line="${line_type}${delimiter}${session_name}${delimiter}${window_number}${delimiter}${window_active}${delimiter}${window_flags}${delimiter}${pane_index}${delimiter}${pane_title}${delimiter}${dir}${delimiter}${pane_active}${delimiter}${pane_command}${delimiter}${pane_full_command}"
      fi
    fi

    printf '%s\n' "$line"
  done < "$RESURRECT_FILE" > "$tmp_file"

  mv "$tmp_file" "$RESURRECT_FILE"
}

patch_resurrect_file
