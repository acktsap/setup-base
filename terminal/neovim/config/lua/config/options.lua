local M = {}

function M.apply()
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"
  -- Keep formatting explicit; project CI or a manual format command should own style changes.
  vim.g.autoformat = false
  vim.g.lazyvim_cmp = "auto"
  vim.g.lazyvim_picker = "auto"

  vim.opt.autoread = true
  vim.opt.backup = false
  vim.opt.confirm = true
  vim.opt.cursorline = false
  vim.opt.errorbells = false
  vim.opt.expandtab = true
  vim.opt.history = 1000
  vim.opt.list = false
  vim.opt.listchars = { tab = "  ", trail = "-", nbsp = "+" }
  vim.opt.number = true
  vim.opt.numberwidth = 3
  vim.opt.relativenumber = true
  vim.opt.shiftwidth = 2
  -- Keep the top row for code; buffer navigation stays in pickers and commands.
  vim.opt.showtabline = 0
  vim.opt.smartindent = true
  vim.opt.swapfile = false
  vim.opt.tabstop = 2
  vim.opt.updatetime = 500
  vim.opt.visualbell = true
  -- Avoid expensive soft-wrap redraws on long Java and log lines.
  vim.opt.wrap = false
end

M.apply()

return M
