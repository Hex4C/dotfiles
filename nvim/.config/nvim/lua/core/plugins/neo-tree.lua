-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true,
      filesystem = {
        -- 'open_default',
        -- "open_current",
        -- hijack_netrw_behavior = 'disabled',
      },
      window = {
        position = 'float',
        width = 30,
      },
      open_on_startup = false,
    }

    -- Set global key mapping to toggle Neo-tree with Ctrl+b
    vim.keymap.set('n', '<C-b>', ':Neotree toggle left<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>wr', ':Neotree reveal left<CR>', { noremap = true, silent = true, desc = '[W]orkspace [R]eveal file' })
  end,
}
