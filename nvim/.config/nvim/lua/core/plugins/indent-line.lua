return {
  -- Add indentation guides even on blank lines
  lazy = true,
  event = 'BufRead',
  'lukas-reineke/indent-blankline.nvim',
  -- Enable `lukas-reineke/indent-blankline.nvim`
  -- See `:help ibl`
  main = 'ibl',
  opts = {},
}
