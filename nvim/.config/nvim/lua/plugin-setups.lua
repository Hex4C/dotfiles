-- Rustacean vim config
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
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
  -- dap = {},
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
