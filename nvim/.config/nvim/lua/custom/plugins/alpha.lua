return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  enabled = true,
  init = false,
  opts = function()
    local dashboard = require 'alpha.themes.dashboard'

    -- NOTE: Code and inspiration from Lazyvim
    local logo = [[
 ,`````.          _________
' Code  `,       /_  ___   \
'  ^_^   `.     / O\/  O\   \
 ` , . , '  `.. \__/\___/   /
                 \_\/______/
                 /     /\\\\\
                |     |\\\\\\
                 \      \\\\\\
                  \______/\\\\
            _______ ||_||_______
           (______(((_(((______(@)
    ]]
    -- local logo = [[
    --        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗           Z
    --        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║       Z
    --        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║    z
    --        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  z
    --        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    --        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
    -- ]]

    dashboard.section.header.val = vim.split(logo, '\n')
    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file",       "<cmd> Telescope find_files<cr>"),
      dashboard.button("e", " " .. " File explorer",   "<cmd> Neotree float <cr>"),
      -- BUG: Currently a little bit broken, will look into it more later
      -- dashboard.button("n", " " .. " New file",        [[<cmd> ene <BAR> startinsert <cr>]]),
      dashboard.button("r", " " .. " Recent files",    [[<cmd> Telescope oldfiles<cr>]]),
      dashboard.button("c", " " .. " Config",          "<cmd> Telescope find_files cwd=~/.config/nvim <cr>"),
      dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
      -- dashboard.button("m", "" .. " Mason",            "<cmd> Mason <cr>"),
      dashboard.button("q", " " .. " Quit",            "<cmd> qa <cr>"),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = 'AlphaButtons'
      button.opts.hl_shortcut = 'AlphaShortcut'
    end
    dashboard.section.header.opts.hl = 'AlphaHeader'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'
    dashboard.section.footer.opts.hl = 'AlphaFooter'
    dashboard.opts.layout[1].val = 8
    return dashboard
  end,
  config = function(_, dashboard)
    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == 'lazy' then
      vim.cmd.close()
      vim.api.nvim_create_autocmd('User', {
        once = true,
        pattern = 'AlphaReady',
        callback = function()
          require('lazy').show()
        end,
      })
    end

    require('alpha').setup(dashboard.opts)

    -- NOTE: Display performance. Always seeing the time it takes makes me
    -- trip and my mind wanders away when working. Will only display the info
    -- if the loadtime is over a predefined threshold.

    vim.api.nvim_create_autocmd('User', {
      once = true,
      pattern = 'LazyVimStarted',
      callback = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        if ms > 200 then
          dashboard.section.footer.val = '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms'
          pcall(vim.cmd.AlphaRedraw)
        end
      end,
    })
  end,
}
