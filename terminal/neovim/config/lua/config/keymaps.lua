local class_symbols = { "Class", "Interface", "Enum", "Struct" }
local symbol_filter = {
  filter = { default = class_symbols },
  symbols = class_symbols,
}

vim.keymap.set("n", "<C-p>", LazyVim.pick("files"), { desc = "Find Files" })
vim.keymap.set("n", "<C-e>", "<cmd>Neotree toggle reveal position=left<cr>", { desc = "Toggle Explorer" })
vim.keymap.set("n", "<C-n>", function() require("config.new_file").from_explorer_or_current_buffer() end, { desc = "New File from Explorer Directory" })
vim.keymap.set({ "n", "x" }, "<C-.>", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set({ "n", "x" }, "<M-.>", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to Clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank Line to Clipboard" })
-- Expose native path navigation in keymap discovery while keeping Vim's built-in behavior.
vim.keymap.set("n", "gf", "gf", { desc = "Open Path Under Cursor" })
vim.keymap.set("n", "gF", "gF", { desc = "Open Path Under Cursor at Line" })
vim.keymap.set("n", "<C-w>f", "<C-w>f", { desc = "Open Path Under Cursor in Split" })
vim.keymap.set("n", "<C-w>gf", "<C-w>gf", { desc = "Open Path Under Cursor in Tab" })
vim.keymap.set("n", "<leader>fc", LazyVim.pick("lsp_workspace_symbols", symbol_filter), { desc = "Find Class or Type" })
vim.keymap.set("n", "<leader>fm", LazyVim.pick("lsp_symbols"), { desc = "Find File Symbols" })
vim.keymap.set("n", "<leader>fr", LazyVim.pick("lsp_references"), { desc = "Find References" })
vim.keymap.set("n", "<leader>fi", LazyVim.pick("lsp_implementations"), { desc = "Find Implementations" })
