return {
  'dmtrKovalenko/fff.nvim',
  lazy = false, -- The plugin lazy-initialises itself
  build = function()
    -- Downloads a prebuilt binary or falls back to cargo build
    require('fff.download').download_or_build_binary()
  end,
  opts = {
    prompt = '> ',
    layout = {
      height = 0.8,
      width = 0.8,
      -- Replicates Telescope's top-oriented search experience:
      prompt_position = 'top', -- Change from 'bottom' to match Telescope
      preview_position = 'right',
      preview_size = 0.5,
      anchor = 'center',
    },
    debug = {
      -- enabled = true,
      -- show_scores = true,
    },
    keymaps = {
      close = { '<Esc>', '<C-c>' },
      select = '<CR>',
      select_split = '<C-s>',
      select_vsplit = '<C-v>',
      select_tab = '<C-t>',
      move_up = { '<Up>', '<C-p>' },
      move_down = { '<Down>', '<C-n>' },
    },
  },
  config = function(_, opts)
    -- Initialize fff with your options
    require('fff').setup(opts)

    local fff = require 'fff'

    -- 1. Files & Grep (Handled brilliantly by fff)
    vim.keymap.set('n', '<leader>sf', function() fff.find_files() end, { desc = '[S]earch [F]iles (fff)' })
    vim.keymap.set('n', '<leader>sg', function() fff.live_grep() end, { desc = '[S]earch by [G]rep (fff)' })
    vim.keymap.set('n', '<leader>sw', function() fff.live_grep { query = vim.fn.expand '<cword>' } end, { desc = '[S]earch current [W]ord' })

    -- "Search All" -> fff handles ignored/hidden files automatically or via arguments depending on your global setup
    vim.keymap.set('n', '<leader>sa', function() fff.find_files() end, { desc = '[S]earch [A]ll files' })

    -- Search Neovim configuration directory using fff
    vim.keymap.set('n', '<leader>sn', function() fff.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })

    -- vim.keymap.set('n', '<leader><leader>', function() fff.live_grep { grep = { modes = { 'fuzzy', 'plain' } } } end, { desc = 'Live fffuzy grep' })
  end,
}
