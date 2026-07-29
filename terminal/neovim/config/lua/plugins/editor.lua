local function move_neo_tree(state, motion)
  vim.api.nvim_set_current_win(state.winid)
  vim.cmd("normal! " .. motion)

  local previous_config = state.config
  state.config = vim.tbl_deep_extend("force", {}, previous_config or {}, { use_float = false })
  require("neo-tree.sources.common.commands").preview(state)
  state.config = previous_config
end

local function focus_and_move(motion)
  local state = require("neo-tree.sources.manager").get_state("filesystem")
  if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then
    move_neo_tree(state, motion)
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<C-j>", function() focus_and_move("j") end, desc = "Focus Explorer and Move Down" },
      { "<C-k>", function() focus_and_move("k") end, desc = "Focus Explorer and Move Up" },
    },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      git_status_scope_to_path = true,
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      filesystem = {
        async_directory_scan = "always",
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        -- Neo-tree only collapses full Java package chains after loading descendant dirs.
        scan_mode = "deep",
        use_libuv_file_watcher = false,
      },
      window = {
        width = 48,
        mappings = {
          ["<C-j>"] = {
            function(state)
              move_neo_tree(state, "j")
            end,
            config = { use_float = false },
          },
          ["<C-k>"] = {
            function(state)
              move_neo_tree(state, "k")
            end,
            config = { use_float = false },
          },
          ["<C-n>"] = function(state)
            require("config.new_file").from_neo_tree(state)
          end,
          ["<C-h>"] = "close_node",
          ["<C-l>"] = "open",
          ["H"] = "toggle_hidden",
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
    },
  },
}
