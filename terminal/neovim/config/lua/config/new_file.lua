local M = {}
local file_types = {
  require("config.new_file.java"),
}

local function is_absolute(path)
  return path:sub(1, 1) == "/" or path:sub(1, 1) == "~"
end

local function normalize(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function dirname(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

local function initial_content(path)
  for _, file_type in ipairs(file_types) do
    local lines = file_type.initial_content(path)
    if lines then
      return lines
    end
  end
  return {}
end

local function prepare_path(path)
  for _, file_type in ipairs(file_types) do
    path = file_type.prepare_path(path)
  end
  return path
end

local function base_dir_from_neo_tree_state(state)
  if not state or not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
    return
  end

  local node = state.tree and state.tree:get_node()
  local base_dir = node and node.path or state.path
  if node and node.type ~= "directory" then
    base_dir = dirname(node.path)
  end
  return base_dir
end

local function visible_neo_tree_state()
  local ok, manager = pcall(require, "neo-tree.sources.manager")
  if not ok then
    return
  end

  local state = manager.get_state("filesystem")
  if base_dir_from_neo_tree_state(state) then
    return state
  end
end

local function edit_file(path, avoid_win, open)
  if open == false then
    return
  end

  local function can_edit_in(win)
    if not win or win == 0 or not vim.api.nvim_win_is_valid(win) or win == avoid_win then
      return false
    end
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.bo[buf].filetype ~= "neo-tree"
  end

  local target = vim.api.nvim_get_current_win()
  if not can_edit_in(target) then
    local alternate = vim.fn.win_getid(vim.fn.winnr("#"))
    target = can_edit_in(alternate) and alternate or nil
  end

  if not target then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if can_edit_in(win) then
        target = win
        break
      end
    end
  end

  if target then
    vim.api.nvim_set_current_win(target)
  end
  vim.cmd.edit(vim.fn.fnameescape(path))
end

function M.create(base_dir, name, opts)
  opts = opts or {}
  base_dir = normalize(base_dir ~= "" and base_dir or vim.uv.cwd())

  if not name then
    local short_dir = vim.fn.fnamemodify(base_dir, ":~:.")
    name = vim.fn.input("New file in " .. short_dir .. ": ", "", "file")
  end

  name = vim.trim(name or "")
  if name == "" then
    return
  end

  local path = normalize(is_absolute(name) and name or vim.fs.joinpath(base_dir, name))
  path = prepare_path(path)

  local parent = dirname(path)
  local ok_mkdir, mkdir_result = pcall(vim.fn.mkdir, parent, "p")
  if (not ok_mkdir or mkdir_result == 0) and vim.fn.isdirectory(parent) == 0 then
    vim.notify("Could not create directory: " .. parent, vim.log.levels.ERROR)
    return
  end

  if vim.uv.fs_stat(path) then
    vim.notify("File already exists: " .. vim.fn.fnamemodify(path, ":~:."))
    edit_file(path, opts.avoid_win, opts.open)
    return path
  end

  local ok, err = pcall(vim.fn.writefile, initial_content(path), path)
  if not ok then
    vim.notify("Could not create file: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.notify("Created " .. vim.fn.fnamemodify(path, ":~:."))
  edit_file(path, opts.avoid_win, opts.open)
  return path
end

function M.from_current_buffer()
  local current = vim.api.nvim_buf_get_name(0)
  local base_dir = current ~= "" and dirname(current) or vim.uv.cwd()
  return M.create(base_dir)
end

function M.from_explorer_or_current_buffer()
  local state = visible_neo_tree_state()
  if state then
    return M.from_neo_tree(state)
  end
  return M.from_current_buffer()
end

function M.from_neo_tree(state)
  local base_dir = base_dir_from_neo_tree_state(state) or vim.uv.cwd()

  local path = M.create(base_dir, nil, { avoid_win = state.winid })
  if path then
    pcall(require("neo-tree.sources.manager").refresh, state.name or "filesystem")
  end
end

return M
