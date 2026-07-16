local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    path_display = { 'smart' },
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      },
    },
  },
})

vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Find project file' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Search project text' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find open buffer' })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find diagnostics' })
vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, { desc = 'Find workspace symbol' })
local function find_classes()
  builtin.lsp_dynamic_workspace_symbols({
    symbols = { 'class', 'interface', 'enum', 'struct' },
  })
end

vim.keymap.set('n', '<leader>fc', find_classes, { desc = 'Find class or type' })
vim.keymap.set('n', '<leader>fm', builtin.lsp_document_symbols, { desc = 'Find method or file symbol' })
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Find implementations' })
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Toggle project diagnostics' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Toggle file diagnostics' })
