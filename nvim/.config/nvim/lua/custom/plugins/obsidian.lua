return {
  'obsidian-nvim/obsidian.nvim',
  lazy = true,
  version = '*', -- use latest release, remove to use latest commit
  -- ft = 'markdown',
  -- event = 'VimEnter',
  event = {
    'BufReadPre /Users/jesperlindeberg/Documents/Obsidian/obsidian-notes/JespersVault/*.md',
    'BufNewFile /Users/jesperlindeberg/Documents/Obsidian/obsidian-notes/JespersVault/*.md',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    callbacks = {
      enter_note = function(_)
        -- Set the conceallevel to 1 (window-local, so other buffers stay at 0)
        vim.opt_local.conceallevel = 1

        if vim.b.obsidian_maps_initialized then return end
        pcall(vim.keymap.del, 'n', '<CR>', { buffer = true })
        pcall(vim.keymap.del, 'n', '<leader><CR>', { buffer = true })

        -- 2. Search & Navigation Commands
        vim.keymap.set('n', '<leader><CR>', '<CMD>Obsidian smart_action<CR>', {
          buffer = true,
          desc = '[O]bsidian Smart action',
        })

        -- One keymap is duplicated here but it is more comfortable with <leader>os
        vim.keymap.set('n', '<leader>og', '<CMD>Obsidian search<CR>', {
          buffer = true,
          desc = '[O]bsidian [G]rep search notes',
        })
        vim.keymap.set('n', '<leader>os', '<CMD>Obsidian search<CR>', {
          buffer = true,
          desc = '[O]bsidian [s]earch notes',
        })
        vim.keymap.set('n', '<leader>of', '<CMD>Obsidian quick_switch<CR>', {
          buffer = true,
          desc = '[O]bsidian [F]ind / quick switch note',
        })

        -- vim.keymap.set('n', '<leader>ow', '<CMD>Obsidian workspace<CR>', {
        --   buffer = true,
        --   desc = '[O]bsidian [W]orkspace switch',
        -- })

        -- Links & Backlinks
        vim.keymap.set('n', '<leader>ol', '<CMD>Obsidian links<CR>', {
          buffer = true,
          desc = '[O]bsidian [L]inks list',
        })
        vim.keymap.set('v', '<leader>ol', '<CMD>Obsidian link<CR>', {
          buffer = true,
          desc = '[O]bsidian [L]ink visual selection to existing note',
        })
        vim.keymap.set('n', '<leader>ob', '<CMD>Obsidian backlinks<CR>', {
          buffer = true,
          desc = '[O]bsidian [B]acklinks for current note',
        })

        -- Creation & Customization
        vim.keymap.set('n', '<leader>on', '<CMD>Obsidian new<CR>', {
          buffer = true,
          desc = '[O]bsidian [N]ew note',
        })
        vim.keymap.set({ 'v', 'x' }, '<leader>on', '<CMD>Obsidian link_new<CR>', {
          buffer = true,
          desc = '[O]bsidian [N]ew note from visual selection',
        })
        vim.keymap.set('n', '<leader>or', '<CMD>Obsidian rename<CR>', {
          buffer = true,
          desc = '[O]bsidian [R]ename note file',
        })
        vim.keymap.set('n', '<leader>oc', '<CMD>Obsidian toc<CR>', {
          buffer = true,
          desc = '[O]bsidian [C]ontents table (TOC)',
        })

        -- Paste hyperlinks for obsidian.nvim
        vim.keymap.set('n', '<C-k>', function()
          local clipboard = vim.fn.getreg('+'):gsub('%s+', '')

          if clipboard:match '^https?://' or clipboard:match '^www%.' then
            local link_snippet = ' [](' .. clipboard .. ')'
            vim.api.nvim_put({ link_snippet }, 'c', false, true)
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local new_col = col - (#clipboard + 3)
            vim.api.nvim_win_set_cursor(0, { row, new_col })
            vim.cmd 'startinsert'
          else
            vim.notify('Clipboard does not contain a valid URL!', vim.log.levels.WARN)
          end
        end, { desc = 'Paste URL as Markdown link skeleton and enter insert mode' })

        vim.b.obsidian_maps_initialized = true
      end,
    },
    legacy_commands = false, -- this will be removed in 4.0.0
    frontmatter = {
      enabled = true,
    },

    -- PARA inbox
    new_notes_location = 'notes_subdir',
    notes_subdir = '05_INBOX',

    completion = {
      min_chars = 2,
      match_case = true,
      create_new = true,
    },
    ui = {
      enable = true,
      ignore_conceal_warn = true,
    },
    picker = {
      name = 'telescope.nvim',
    },
    workspaces = {
      {
        name = 'Main vault',
        path = '~/Documents/Obsidian/obsidian-notes/JespersVault/',
      },
    },
    footer = {
      enabled = true,
      format = '{{backlinks}} backlinks',
      hl_group = 'Comment',
      separator = string.rep('-', 80),
    },
  },
}
