-- Rustacean vim config
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
    -- NOTE: Disable nextest to avoid having to install it now, probably
    -- install in the future since it looks good, fast.
    enable_nextest = false,
  },
  -- LSP configuration
  -- WARN: Unused code below
  --
  -- server = {
  --   on_attach = function(client, bufnr)
  --     -- you can also put keymaps in here
  --   end,
  --   default_settings = {
  --     -- rust-analyzer language server configuration
  ['rust-analyzer'] = {
    cargo = {
      allFeatures = true,
      loadOutDirsFromCheck = true,
      buildScripts = {
        enable = true,
      },
    },
  },
  --   },
  -- },
  -- -- DAP configuration
  -- dap = {},
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
