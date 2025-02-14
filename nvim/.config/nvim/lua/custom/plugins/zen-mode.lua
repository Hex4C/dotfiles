return {
  'folke/zen-mode.nvim',
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    options = {
      number = true,
    },
    plugin = {
      options = {
        enabled = true,
        ruler = false, -- disables the ruler text in the cmd line area
        showcmd = false, -- disables the command in the last line of the screen
        -- you may turn on/off statusline in zen mode by setting 'laststatus'
        -- statusline will be shown only if 'laststatus' == 3
        laststatus = 0, -- turn off the statusline in zen mode
      },
      gitsigns = { enabled = true }, -- disables git signs
      tmux = { enabled = false }, -- disables the tmux statusline
      todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled

      -- this will change the font size on alacritty when in zen mode
      -- requires  Alacritty Version 0.10.0 or higher
      -- uses `alacritty msg` subcommand to change font size
      alacritty = {
        enabled = false,
        font = '14', -- font size
      },
    },
  },
}
