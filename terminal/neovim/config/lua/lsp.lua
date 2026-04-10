-- LSP keymaps (set when a server attaches to a buffer)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buf = args.buf
    local opts = { buffer = buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- highlight symbol under cursor (like IDE)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Shared capabilities (nvim-cmp integration)
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSP servers (vim.lsp.config + vim.lsp.enable, neovim 0.11+ native API)
-- server name -> binary name
local servers = {
  clangd = 'clangd',
  gopls = 'gopls',
  jdtls = 'jdtls',
  bashls = 'bash-language-server',
}
local enabled = {}

for name, binary in pairs(servers) do
  vim.lsp.config(name, { capabilities = capabilities })
  if vim.fn.executable(binary) == 1 then
    table.insert(enabled, name)
  end
end

vim.lsp.enable(enabled)
