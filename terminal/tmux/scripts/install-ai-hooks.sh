#!/usr/bin/env bash
# Install Claude/Codex hooks that feed tmux AI status files.

set -euo pipefail

HOOK_BIN="${TMUX_AI_HOOK_BIN:-/usr/local/bin/tmux-ai-hook}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

require_jq() {
  command -v jq >/dev/null 2>&1 || {
    echo "jq is required to merge hook settings" >&2
    exit 1
  }
}

backup_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  cp -p "$file" "${file}.tmux-ai-hooks.$(date +%Y%m%d%H%M%S).bak"
}

install_codex_hooks() {
  local hooks_file="$CODEX_HOME/hooks.json"
  local config_file="$CODEX_HOME/config.toml"
  local tmp

  mkdir -p "$CODEX_HOME"
  if [[ ! -f "$hooks_file" ]]; then
    printf '{"hooks":{}}\n' > "$hooks_file"
  fi
  backup_file "$hooks_file"

  tmp="${hooks_file}.tmp.$$"
  jq --arg hook "$HOOK_BIN" '
    def without_tmux_ai:
      if type == "array" then
        map(.hooks = ((.hooks // []) | map(select(((.command // "") | contains("tmux-ai-hook") | not))))
          | select((.hooks // []) | length > 0))
      else
        []
      end;

    .hooks = (.hooks // {})
    | .hooks.SessionStart =
        ((.hooks.SessionStart | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " codex session-start"), "timeout": 5 }] }])
    | .hooks.UserPromptSubmit =
        ((.hooks.UserPromptSubmit | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " codex prompt-submit"), "timeout": 5 }] }])
    | .hooks.Stop =
        ((.hooks.Stop | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " codex stop"), "timeout": 5 }] }])
  ' "$hooks_file" > "$tmp"
  mv "$tmp" "$hooks_file"

  touch "$config_file"
  backup_file "$config_file"
  tmp="${config_file}.tmp.$$"
  awk '
    BEGIN {
      in_features = 0
      saw_features = 0
      saw_hooks = 0
    }
    function insert_hooks() {
      if (in_features && !saw_hooks) {
        print "hooks = true"
        saw_hooks = 1
      }
    }
    /^\[[^]]+\][[:space:]]*$/ {
      insert_hooks()
      in_features = ($0 ~ /^\[features\][[:space:]]*$/)
      saw_features = saw_features || in_features
      print
      next
    }
    in_features && /^[[:space:]]*codex_hooks[[:space:]]*=/ {
      next
    }
    in_features && /^[[:space:]]*hooks[[:space:]]*=/ {
      print "hooks = true"
      saw_hooks = 1
      next
    }
    { print }
    END {
      insert_hooks()
      if (!saw_features) {
        print ""
        print "[features]"
        print "hooks = true"
      }
    }
  ' "$config_file" > "$tmp"
  mv "$tmp" "$config_file"
}

install_claude_hooks() {
  local settings_file="$CLAUDE_HOME/settings.json"
  local tmp

  mkdir -p "$CLAUDE_HOME"
  if [[ ! -f "$settings_file" ]]; then
    printf '{}\n' > "$settings_file"
  fi
  backup_file "$settings_file"

  tmp="${settings_file}.tmp.$$"
  jq --arg hook "$HOOK_BIN" '
    def without_tmux_ai:
      if type == "array" then
        map(.hooks = ((.hooks // []) | map(select(((.command // "") | contains("tmux-ai-hook") | not))))
          | select((.hooks // []) | length > 0))
      else
        []
      end;

    .hooks = (.hooks // {})
    | .hooks.SessionStart =
        ((.hooks.SessionStart | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " claude session-start"), "timeout": 5 }] }])
    | .hooks.UserPromptSubmit =
        ((.hooks.UserPromptSubmit | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " claude prompt-submit"), "timeout": 5 }] }])
    | .hooks.PreToolUse =
        ((.hooks.PreToolUse | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " claude pre-tool-use"), "timeout": 5 }] }])
    | .hooks.Notification =
        ((.hooks.Notification | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " claude notification"), "timeout": 5 }] }])
    | .hooks.Stop =
        ((.hooks.Stop | without_tmux_ai)
          + [{ "hooks": [{ "type": "command", "command": ($hook + " claude stop"), "timeout": 5 }] }])
  ' "$settings_file" > "$tmp"
  mv "$tmp" "$settings_file"
}

main() {
  require_jq
  install_codex_hooks
  install_claude_hooks
  echo "Installed tmux AI hooks for Claude and Codex."
}

main "$@"
