vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99
vim.o.foldtext = ''
vim.o.foldcolumn = '0' -- Keep the default column hidden

-- Fill chars
vim.opt.fillchars = {
  eob = ' ',
  fold = ' ',
  foldopen = '',
  foldsep = ' ',
  foldclose = '',
}

function _G.get_fold_virt(lnum)
  if vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1) then return vim.fn.foldclosed(lnum) == -1 and '' or '' end
  return ' '
end
vim.o.statuscolumn = '%s%l %{v:lua.get_fold_virt(v:lnum)} '

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method 'textDocument/foldingRange' then
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})
