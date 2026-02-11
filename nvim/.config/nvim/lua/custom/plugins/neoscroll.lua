return {
  'karb94/neoscroll.nvim',
  opts = {
    duration_multiplier = 1.0,
    performance_mode = true,
  },
  event = 'VeryLazy',
  config = function()
    local neoscroll = require 'neoscroll'
    neoscroll.setup {
      mappings = {
        '<C-u>',
        '<C-d>',
        '<C-f>',
        '<C-y>',
        '<C-e>',
        'zt',
        'zz',
        'zb',
      },
      easing = 'cubic',
    }
    local modes = { 'n', 'v', 'x' }

    -- 1. Define the functions once
    local scroll_up = function()
      neoscroll.ctrl_u { duration = 100, easing = 'sine' }
    end
    local scroll_down = function()
      neoscroll.ctrl_d { duration = 100, easing = 'sine' }
    end
    local scroll_fwd = function()
      neoscroll.ctrl_f { duration = 300, easing = 'sine' }
    end
    local scroll_y = function()
      neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
    end
    local scroll_e = function()
      neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
    end

    -- 2. Create tables to group keys with the same action
    local key_groups = {
      -- C-u and ä both scroll up
      ['<C-u>'] = scroll_up,
      ['ä'] = scroll_up,
      -- C-d and ö both scroll down
      ['<C-d>'] = scroll_down,
      ['ö'] = scroll_down,
      -- Other existing mappings
      ['<C-f>'] = scroll_fwd,
      ['<C-y>'] = scroll_y,
      ['<C-e>'] = scroll_e,
    }

    -- 3. Loop through the key groups to set the keymaps
    for key, func in pairs(key_groups) do
      vim.keymap.set(modes, key, func, { desc = 'Neoscroll: ' .. key })
    end
  end,
}
