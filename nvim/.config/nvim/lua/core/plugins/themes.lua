return {
  'catppuccin/nvim',
  name = 'catppuccin',
  -- version = '2.0.0',
  priority = 1000,
  opts = {
    flavour = 'mocha',
    compile_path = vim.fn.stdpath 'cache' .. '/catppuccin',
    no_italic = true,
    no_bold = true,
    auto_integrations = false,
    integrations = {
      alpha = true,
      blink_cmp = true,
      flash = true,
      gitsigns = true,
      harpoon = true,
      indent_blankline = { enabled = true },
      mini = { enabled = true },
      neotree = true,
      noice = true,
      telescope = { enabled = true },
      snacks = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin-nvim'
  end,
}

-- { -- You can easily change to a different colorscheme.
--   -- Change the name of the colorscheme plugin below, and then
--   -- change the command in the config to whatever the name of that colorscheme is.
--   --
--   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--   'folke/tokyonight.nvim',
--   -- priority = 10, -- Make sure to load this before all the other start plugins.
--   init = function()
--     -- Load the colorscheme here.
--     -- Like many other themes, this one has different styles, and you could load
--     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
--     -- catppuccin-macchiato is the slightly lighter version of mocha
--     vim.cmd.colorscheme 'catppuccin-mocha'
--
--     -- You can configure highlights by doing something like:
--     vim.cmd.hi 'Comment gui=none'
--   end,
