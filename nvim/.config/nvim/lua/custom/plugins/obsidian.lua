return {
  'obsidian-nvim/obsidian.nvim',
  lazy = true,
  version = '*', -- use latest release, remove to use latest commit
  -- ft = 'markdown',
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
    legacy_commands = false, -- this will be removed in 4.0.0
    frontmatter = {
      enabled = true,
    },
    completion = {
      min_chars = 2,
      match_case = true,
      create_new = true,
    },
    ui = {
      enable = true,
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
