return {
  -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Add icons
    require('mini.icons').setup()

    -- Add comments fix (mainly for rust)
    -- // Would become //test in rust
    require('mini.comment').setup()

    -- Auto pairs, same as autopairs but perhaps better?
    -- require('mini.pairs').setup()

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    -- Load the plugin
    local statusline = require 'mini.statusline'

    -- Optional: Only use icons if you have a Nerd Font
    statusline.setup {
      use_icons = vim.g.have_nerd_font or false,
    }

    -- Function to show macro recording status
    local function macro_status()
      local reg = vim.fn.reg_recording()
      if reg == '' then
        return ''
      else
        return 'REC @' .. reg .. ' '
      end
    end

    -- Override section_location to include macro indicator and custom format
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      -- Format: REC @x 12:34 or just 12:34 if not recording
      return macro_status() .. '%2l:%-2v'
    end

    -- Redraw the statusline when macro recording starts or stops
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        vim.cmd 'redrawstatus'
      end,
    })

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
