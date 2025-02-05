return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>st',
      function()
        vim.cmd 'silent! TodoTelescope'
      end,
      mode = 'n',
      desc = '[S]Search [T]odo',
    },
  },
  opts = { signs = false },
}
