return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      local function collect_bundles()
        local bundles = vim.fn.glob("$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar", false, true)
        for _, jar in ipairs(vim.fn.glob("$MASON/share/java-test/*.jar", false, true)) do
          local name = vim.fn.fnamemodify(jar, ":t")
          if name ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" and name ~= "jacocoagent.jar" then
            table.insert(bundles, jar)
          end
        end
        return bundles
      end

      opts.dap_main = false
      opts.jdtls = function(config)
        config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
          bundles = collect_bundles(),
        })
        return config
      end
      if vim.fn.executable("/opt/homebrew/bin/jdtls") == 1 then
        opts.cmd = { "/opt/homebrew/bin/jdtls" }
        for _, jar in ipairs({
          vim.fn.stdpath("data") .. "/java/lombok.jar",
          vim.fn.expand("$MASON/share/jdtls/lombok.jar"),
        }) do
          if (vim.uv or vim.loop).fs_stat(jar) then
            table.insert(opts.cmd, "--jvm-arg=-javaagent:" .. jar)
            break
          end
        end
      end
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          -- Keep JDTLS responsive; reload Gradle explicitly with <leader>ju after build file changes.
          autobuild = { enabled = false },
          completion = {
            favoriteStaticMembers = {
              "org.assertj.core.api.Assertions.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
            },
            importOrder = { "java", "javax", "org", "com" },
          },
          configuration = { updateBuildConfiguration = "interactive" },
          contentProvider = { preferred = "fernflower" },
          eclipse = { downloadSources = true },
          gradle = { downloadSources = true, enabled = true },
          inlayHints = {
            parameterNames = {
              -- Prevent JDTLS from restoring argument-name hints if inlay hints are toggled manually.
              enabled = "none",
            },
          },
          import = {
            gradle = {
              enabled = true,
              wrapper = { enabled = true },
            },
          },
          maven = { downloadSources = true },
          references = { includeDecompiledSources = true },
          -- Keep edits explicit; CI remains the source of truth for project Checkstyle.
          saveActions = { organizeImports = false },
          signatureHelp = { enabled = true },
        },
      })

      local on_attach = opts.on_attach
      opts.on_attach = function(args)
        if on_attach then
          on_attach(args)
        end

        local jdtls = require("jdtls")
        local jdtls_dap = require("jdtls.dap")
        local map_opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, vim.tbl_extend("force", map_opts, { desc = "Java Organize Imports" }))
        vim.keymap.set("n", "<leader>jv", jdtls.extract_variable_all, vim.tbl_extend("force", map_opts, { desc = "Java Extract Variable" }))
        vim.keymap.set("x", "<leader>jv", function() jdtls.extract_variable_all(true) end, vim.tbl_extend("force", map_opts, { desc = "Java Extract Variable" }))
        vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, vim.tbl_extend("force", map_opts, { desc = "Java Extract Constant" }))
        vim.keymap.set("x", "<leader>jc", function() jdtls.extract_constant(true) end, vim.tbl_extend("force", map_opts, { desc = "Java Extract Constant" }))
        vim.keymap.set("x", "<leader>jm", function() jdtls.extract_method(true) end, vim.tbl_extend("force", map_opts, { desc = "Java Extract Method" }))
        vim.keymap.set("n", "<leader>ju", "<cmd>JdtUpdateConfig<cr>", vim.tbl_extend("force", map_opts, { desc = "Java Reload Project" }))
        vim.keymap.set("n", "<C-t>", require("jdtls.tests").goto_subjects, vim.tbl_extend("force", map_opts, { desc = "Java Goto Test or Subject" }))
        vim.keymap.set("n", "<leader>jt", function() jdtls_dap.test_nearest_method() end, vim.tbl_extend("force", map_opts, { desc = "Java Test Nearest Method" }))
        vim.keymap.set("n", "<leader>jT", function() jdtls_dap.test_class() end, vim.tbl_extend("force", map_opts, { desc = "Java Test Class" }))
      end
    end,
  },
}
