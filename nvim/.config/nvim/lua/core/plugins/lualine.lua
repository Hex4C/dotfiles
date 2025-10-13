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
        'filename',
        function()
          local reg = vim.fn.reg_recording()
          -- If a macro is being recorded, show "Recording @<register>"
          if reg ~= '' then
            return 'REC @' .. reg
          end
          return ''
        end,
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
