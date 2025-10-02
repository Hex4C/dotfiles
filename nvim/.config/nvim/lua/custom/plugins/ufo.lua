return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'luukvbaal/statuscol.nvim',
  },
  event = 'VeryLazy',
  config = function()
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    local fcs = vim.opt.fillchars:get()

    -- Stolen from Akinsho
    local function get_fold(lnum)
      if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
        return ' '
      end
      local fold_sym = vim.fn.foldclosed(lnum) == -1 and fcs.foldopen or fcs.foldclose
      return fold_sym
    end
    _G.get_statuscol = function()
      return '%s%l' .. get_fold(vim.v.lnum) .. ' '
    end

    vim.o.statuscolumn = '%!v:lua.get_statuscol()'
    -- local builtin = require 'statuscol.builtin'
    -- require('statuscol').setup {
    --   segments = {
    --     { text = { '%s' }, click = 'v:lua.ScSa' },
    --     { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
    --     {
    --       text = { ' ', builtin.foldfunc, ' ' },
    --       condition = { builtin.not_empty, true, builtin.not_empty },
    --       click = 'v:lua.ScFa',
    --     },
    --   },
    -- }
    -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    require('ufo').setup {
      provider_selector = function(_, _, _)
        return { 'treesitter', 'indent' }
      end,
    }
  end,
}
