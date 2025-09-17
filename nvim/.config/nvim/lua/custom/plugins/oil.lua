return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  -- dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function()
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    vim.keymap.set('n', '\\', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    require('oil').setup {
      delete_to_trash = false,
      default_file_explorer = false,
      columns = {
        'icon',
        'size',
      },
      view_options = {
        show_hidden = true,
      },
    }
  end,
}
