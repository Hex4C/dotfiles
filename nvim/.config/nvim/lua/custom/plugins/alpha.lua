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
    '  ^_^  `,       /_  ___   \
    '        `.     / O\/  O\   \
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

    local fff = require 'fff'
    dashboard.section.header.val = vim.split(logo, '\n')
    -- stylua: ignore
    dashboard.section.buttons.val = {
      dashboard.button("f", "󰈞  Find/recent file", "<cmd>lua require('fff').find_files()<CR>"),
      dashboard.button("g", "󰱽  Live grep", "<cmd>lua require('fff').live_grep()<CR>"),
      dashboard.button("e", " " .. " File explorer",   "<cmd> Neotree float <cr>"), -- Strings still work too!
      -- dashboard.button("r", " " .. " Recent files",    "<cmd>lua require('fff').find_files()<CR>"),
      dashboard.button("c", " " .. " Config",         "<cmd>lua require('fff').find_files({ cwd = vim.fn.stdpath('config') })<CR>"),
      dashboard.button("l", "󰒲 " .. " Lazy",            "<cmd> Lazy <cr>"),
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
        callback = function() require('lazy').show() end,
      })
    end

    require('alpha').setup(dashboard.opts)

    -- NOTE: Reopen the dashboard when an explorer opened from alpha is closed.
    local explorer_fts = { oil = true, ['neo-tree'] = true }
    local came_from_explorer = false
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('alpha_explorer_restore', { clear = true }),
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if explorer_fts[ft] then
          came_from_explorer = true
          return
        end
        if not came_from_explorer then return end
        came_from_explorer = false
        -- only restore alpha if we ended up on a blank, normal buffer
        if vim.bo[args.buf].buftype == '' and ft == '' and vim.api.nvim_buf_get_name(args.buf) == '' then require('alpha').start(false) end
      end,
    })

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
