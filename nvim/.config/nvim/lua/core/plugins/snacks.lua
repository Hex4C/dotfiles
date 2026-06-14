return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true, notify = true, line_length = 1000, size = 2 * 1024 * 1024 },
    scope = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },

    scratch = {
      enabled = false,
      name = 'Notes',
      ft = 'markdown',
      win = { style = 'scratch' },
      on_attach = function(buf)
        vim.diagnostic.enable(false, { bufnr = buf })
        vim.api.nvim_create_autocmd('LspAttach', {
          buffer = buf,
          callback = function(args) vim.lsp.buf_detach(args.data.client_id, buf) end,
        })
      end,
    },

    dashboard = { enabled = false },
    indent = { enabled = false },
    -- Maybe enable image later but requires a few deps
    image = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    notify = { enabled = false },
    statuscolumn = { enabled = false },
    terminal = { enabled = false },
    toggle = { enabled = false },
    win = { enabled = false },
    zen = { enabled = false },
  },
  keys = {
    -- Keybinds cleanly commented out as you had them
    -- { '<leader>Z', function() Snacks.zen() end, desc = 'Toggle Zen Mode' },
    -- { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    -- { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
  },
}
