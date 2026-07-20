local options = require("config.options")
require("config.lazy")
-- LazyVim sets display defaults during setup; reapply local preferences after it finishes.
options.apply()
-- Keymaps use LazyVim helpers, so load them after LazyVim has initialized.
require("config.keymaps")
require("config.autocmds")
