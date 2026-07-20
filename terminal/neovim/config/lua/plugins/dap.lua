return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug Continue" },
      { "<F6>", function() require("dap").pause() end, desc = "Debug Pause" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug Step Out" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle Debugger UI" },
    },
  },
}
