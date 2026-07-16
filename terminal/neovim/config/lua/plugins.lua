local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function move_neo_tree(state, motion)
  vim.api.nvim_set_current_win(state.winid)
  vim.cmd("normal! " .. motion)

  local previous_config = state.config
  state.config = vim.tbl_deep_extend("force", {}, previous_config or {}, { use_float = false })
  require("neo-tree.sources.common.commands").preview(state)
  state.config = previous_config
end

require("lazy").setup({
  -- UI / Themes & Statusline
  {
    "sonph/onehalf",
    lazy = false,
    priority = 1000,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end,
  },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Navigating
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<C-e>", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle file explorer" },
    },
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      close_if_last_window = true,
      git_status_scope_to_path = true,
      filesystem = {
        follow_current_file = { enabled = true },
        group_empty_dirs = true,
        use_libuv_file_watcher = true,
      },
      window = {
        width = 38,
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
          ["<C-h>"] = "close_node",
          ["<C-l>"] = "open",
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      local function focus_and_move(motion)
        local state = require("neo-tree.sources.manager").get_state("filesystem")
        if state and state.winid and vim.api.nvim_win_is_valid(state.winid) then
          move_neo_tree(state, motion)
        end
      end

      vim.keymap.set("n", "<C-j>", function()
        focus_and_move("j")
      end, { desc = "Focus explorer and move down" })
      vim.keymap.set("n", "<C-k>", function()
        focus_and_move("k")
      end, { desc = "Focus explorer and move up" })
    end,
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-neo-tree/neo-tree.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  -- LSP / Completion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", opts = {} },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Project navigation
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Java IDE features
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    opts = {},
  },

  -- Git
  { "tpope/vim-fugitive" },
  { "airblade/vim-gitgutter" },

  -- Language
  { "fatih/vim-go" },
})
