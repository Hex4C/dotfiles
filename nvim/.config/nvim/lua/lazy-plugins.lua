-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({

  -- import = 'core.plugins',
  require 'core.plugins.guess-indent',

  require 'core.plugins.gitsigns', -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end
  --
  require 'core.plugins.which-key',

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  require 'core.plugins.telescope',

  -- LSP Plugins
  require 'core.plugins.lsp',

  require 'core.plugins.conform',

  require 'core.plugins.blink',

  require 'core.plugins.themes',

  require 'core.plugins.todo-comments',

  require 'core.plugins.lualine',

  require 'core.plugins.mini',

  require 'core.plugins.nvim-treesitter',

  require 'core.plugins.indent-line',
  require 'core.plugins.lint',

  require 'core.plugins.autopairs',
  require 'core.plugins.neo-tree',

  -- TODO: Import the debogger here later
  require 'core.plugins.debug',

  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- NOTE: This import all of my custom plugins in the custom/plugins/* folder
  --
  { import = 'custom.plugins' },
}, {
  rocks = {
    enabled = true,
    hererocks = true,
  },
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
