return {
  -- dir = os.getenv 'HOME' .. '/desktop/github/OpenSource/teamtype/nvim-plugin',
  -- name = 'teamtype-dev',
  'teamtype/teamtype-nvim',
  lazy = false,
  keys = {
    { '<leader>ej', '<cmd>TeamtypeJumpToCursor<cr>' },
    { '<leader>ef', '<cmd>TeamtypeFollow<cr>' },
  },
}
