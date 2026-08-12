return {
  {
    -- Chart templates are Go templates, not YAML; without this they parse as broken YAML.
    "towolf/vim-helm",
    ft = "helm",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("helm_treesitter", { clear = true }),
        pattern = "helm",
        callback = function(args)
          -- vim-helm switches the filetype from yaml to helm only after LazyVim has already
          -- attached the yaml parser, and the yaml tree errors out at the first {{- -}}, leaving
          -- the rest of the buffer uncolored. Swap the highlighter over to the helm parser.
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].filetype ~= "helm" then
              return
            end
            vim.treesitter.stop(args.buf)
            pcall(vim.treesitter.start, args.buf, "helm")
          end)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "helm" } },
  },
}
