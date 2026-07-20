function apply_orca_worktree_settings() {
  local profile_data="${ORCA_PROFILE_DATA_PATH:-${HOME}/Library/Application Support/orca/profiles/local-default/orca-data.json}"

  if [[ ! -f "${profile_data}" ]]; then
    echo "-- Skipping Orca worktree settings; launch Orca once and rerun setup"
    return
  fi

  if pgrep -f "/Applications/Orca.app/Contents/MacOS/Orca" >/dev/null; then
    echo "-- Skipping Orca worktree settings; quit Orca and rerun setup"
    return
  fi

  # orca-data.json also stores volatile project/worktree state; only own the stable fields here.
  node - "${profile_data}" <<'NODE'
const fs = require("fs");

const profileData = process.argv[2];
const data = JSON.parse(fs.readFileSync(profileData, "utf8"));
const settings = data.settings ?? (data.settings = {});
const oldPath = settings.workspaceDir;
const oldNestWorkspaces = settings.nestWorkspaces;
const nextPath = ".worktree";
const nextNestWorkspaces = false;
const history = Array.isArray(settings.workspaceDirHistory) ? settings.workspaceDirHistory : [];

if (oldPath && (oldPath !== nextPath || oldNestWorkspaces !== nextNestWorkspaces)) {
  const exists = history.some(
    (item) => item && item.path === oldPath && item.nestWorkspaces === oldNestWorkspaces
  );
  if (!exists) {
    history.push({ path: oldPath, nestWorkspaces: oldNestWorkspaces });
  }
}

if (
  settings.workspaceDir !== nextPath ||
  settings.nestWorkspaces !== nextNestWorkspaces ||
  settings.workspaceDirHistory !== history
) {
  settings.workspaceDir = nextPath;
  settings.nestWorkspaces = nextNestWorkspaces;
  settings.workspaceDirHistory = history;
  fs.writeFileSync(profileData, JSON.stringify(data));
}
NODE
}
