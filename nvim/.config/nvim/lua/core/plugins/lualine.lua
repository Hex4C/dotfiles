return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      icons_enabled = true,
      component_separators = '|',
      selection_separators = '',
      theme = 'catppuccin-mocha',
      disabled_filetypes = {
        'neo-tree',
        'alpha',
      },
    },
    sections = {
      -- Add the macro recording status in the mode section
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = {
        {
          'filename',
          path = 1, -- 0 = filename, 1 = relative path, 2 = absolute path
          shorting_target = 20, -- shorten if long
          symbols = {
            modified = '●',
            readonly = '',
          },
        },
        {
          function()
            local reg = vim.fn.reg_recording()
            if reg ~= '' then
              return ' REC @' .. reg -- adds a nice recording icon
            end
            return ''
          end,
          color = { fg = '#f38ba8', gui = 'bold' }, -- optional styling
        },
      },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { 'filename' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
