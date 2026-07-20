return {
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      completion = {
        menu = {
          auto_show = true,
        },
        list = {
          selection = {
            auto_insert = false,
            preselect = true,
          },
        },
        trigger = {
          show_on_keyword = true,
          show_on_trigger_character = true,
        },
      },
      keymap = {
        preset = "enter",
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_active() then
              return cmp.select_and_accept()
            end
          end,
          "fallback",
        },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.completion = vim.tbl_deep_extend("force", opts.completion or {}, {
        autocomplete = { cmp.TriggerEvent.TextChanged },
        completeopt = "menu,menuone,noinsert,noselect",
        keyword_length = 1,
      })
      opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-j>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-k>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
