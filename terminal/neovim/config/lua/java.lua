local java_group = vim.api.nvim_create_augroup('JavaJdtls', { clear = true })

local function collect_bundles()
  local mason = vim.fn.stdpath('data') .. '/mason/packages'
  local bundles = vim.fn.glob(mason .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
  local test_jars = vim.fn.glob(mason .. '/java-test/extension/server/*.jar', true, true)

  for _, jar in ipairs(test_jars) do
    local name = vim.fn.fnamemodify(jar, ':t')
    if name ~= 'com.microsoft.java.test.runner-jar-with-dependencies.jar' and name ~= 'jacocoagent.jar' then
      table.insert(bundles, jar)
    end
  end

  return bundles
end

local function project_root()
  local repository_root = vim.fs.root(0, {
    '.git',
    'mvnw',
    'gradlew',
  })
  if repository_root then
    return repository_root
  end

  return vim.fs.root(0, {
    'pom.xml',
    'settings.gradle',
    'settings.gradle.kts',
    'build.gradle',
    'build.gradle.kts',
  }) or vim.fn.getcwd()
end

local function java_workspace(root)
  local project = vim.fn.fnamemodify(root, ':t')
  local identity = vim.fn.sha256(root):sub(1, 12)
  return vim.fn.stdpath('cache') .. '/jdtls/' .. project .. '-' .. identity
end

local function attach_jdtls()
  local jdtls = require('jdtls')
  local root = project_root()
  local extended = vim.deepcopy(jdtls.extendedClientCapabilities)
  local capabilities = vim.tbl_deep_extend(
    'force',
    require('cmp_nvim_lsp').default_capabilities(),
    require('lsp-file-operations').default_capabilities()
  )
  extended.resolveAdditionalTextEditsSupport = true

  jdtls.start_or_attach({
    cmd = { 'jdtls', '-data', java_workspace(root) },
    root_dir = root,
    capabilities = capabilities,
    init_options = {
      bundles = collect_bundles(),
      extendedClientCapabilities = extended,
    },
    settings = {
      java = {
        autobuild = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            'org.assertj.core.api.Assertions.*',
            'org.junit.jupiter.api.Assertions.*',
            'org.mockito.Mockito.*',
          },
          importOrder = { 'java', 'javax', 'org', 'com' },
        },
        configuration = { updateBuildConfiguration = 'automatic' },
        contentProvider = { preferred = 'fernflower' },
        eclipse = { downloadSources = true },
        gradle = { downloadSources = true, enabled = true },
        inlayHints = { parameterNames = { enabled = 'all' } },
        maven = { downloadSources = true },
        references = { includeDecompiledSources = true },
        saveActions = { organizeImports = false },
        signatureHelp = { enabled = true },
      },
    },
    on_attach = function()
      jdtls.setup_dap({ hotcodereplace = 'auto' })
    end,
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = java_group,
  pattern = 'java',
  callback = attach_jdtls,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = java_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'jdtls' then
      return
    end

    local opts = { buffer = args.buf }
    local jdtls = require('jdtls')
    vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, vim.tbl_extend('force', opts, { desc = 'Java organize imports' }))
    vim.keymap.set('n', '<leader>jv', jdtls.extract_variable, vim.tbl_extend('force', opts, { desc = 'Java extract variable' }))
    vim.keymap.set('v', '<leader>jv', function() jdtls.extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Java extract variable' }))
    vim.keymap.set('n', '<leader>jc', jdtls.extract_constant, vim.tbl_extend('force', opts, { desc = 'Java extract constant' }))
    vim.keymap.set('v', '<leader>jc', function() jdtls.extract_constant(true) end, vim.tbl_extend('force', opts, { desc = 'Java extract constant' }))
    vim.keymap.set('v', '<leader>jm', function() jdtls.extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Java extract method' }))
    vim.keymap.set('n', '<leader>ju', '<cmd>JdtUpdateConfig<cr>', vim.tbl_extend('force', opts, { desc = 'Java reload project' }))
    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, vim.tbl_extend('force', opts, { desc = 'Java test nearest method' }))
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, vim.tbl_extend('force', opts, { desc = 'Java test class' }))
  end,
})

local dap = require('dap')
local dapui = require('dapui')

dap.listeners.before.attach.java_dapui = dapui.open
dap.listeners.before.launch.java_dapui = dapui.open
dap.listeners.before.event_terminated.java_dapui = dapui.close
dap.listeners.before.event_exited.java_dapui = dapui.close

vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug continue or start' })
vim.keymap.set('n', '<F6>', dap.pause, { desc = 'Debug pause' })
vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug step over' })
vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug step into' })
vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug step out' })
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle debugger UI' })
