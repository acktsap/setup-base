return {
  -- Keep buffer navigation in pickers/commands instead of reserving a permanent tab strip.
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "snacks.nvim",
    opts = {
      indent = { enabled = false },
      scope = { enabled = false },
    },
  },
}
