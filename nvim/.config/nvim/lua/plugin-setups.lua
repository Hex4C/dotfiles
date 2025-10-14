-- Python setup things
vim.g.python3_host_prog = vim.fn.expand '~/.config/nvim/.venv/bin/python3'

-- Rustacean vim config
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
    -- TODO: Install neotest
    --
    -- Would also require neotest and the neotest-rust adapter
    -- To install nextest the command below.
    -- cargo install nextest --locked
    enable_nextest = false,
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      local opts = { silent = true, buffer = bufnr }

      -- Code Action keymap
      vim.keymap.set({ 'n', 'x' }, '<leader>ca', function()
        vim.cmd.RustLsp 'codeAction' -- Uses rust-analyzer's grouping
      end, { silent = true, buffer = bufnr, desc = '[C]ode [A]ction (RUST)' })

      vim.keymap.set('n', 'K', function()
        vim.cmd.RustLsp { 'hover', 'actions' }
      end, opts)
    end,
    default_settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
      },
    },
  },
  -- DAP configuration (if needed)
  --
  dap = {
    adapter = function()
      local codelldb_pkg = vim.fn.expand '$MASON/packages/codelldb'
      local extension_path = codelldb_pkg .. '/extension/'
      local codelldb_path = extension_path .. 'adapter/codelldb'
      local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
      local cfg = require 'rustaceanvim.config'
      return cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
    end,
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
