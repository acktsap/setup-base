return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Prefer signature/docs popups over inline parameter/type hints in dense Java buffers.
      inlay_hints = { enabled = false },
      servers = {
        bashls = {},
        clangd = {},
        gopls = {},
        helm_ls = {},
        jdtls = { mason = false },
      },
    },
  },
}
