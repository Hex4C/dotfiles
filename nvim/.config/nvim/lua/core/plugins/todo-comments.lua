return {
  'folke/todo-comments.nvim',
  -- NOTE: This adds about 5ms of delay but will cause slight lag
  -- in the rendering of the tags if jumping quickly from a file
  -- without the tags to one with tags.
  --
  -- lazy = true,
  -- event = { 'BufReadPost', 'BufNewFile' },
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>st',
      function() vim.cmd 'silent! TodoTelescope' end,
      mode = 'n',
      desc = '[S]Search [T]odo',
    },
  },
  opts = { signs = false },
}
