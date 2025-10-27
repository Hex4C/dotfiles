-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Add better navigation for nordic keyboard layout
vim.keymap.set('n', 'ä', '{')
vim.keymap.set('n', 'ö', '}')

-- Easier to type : when not on a good keyboard
vim.keymap.set('n', '.', ':')

vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('n', '<C-c>', '<Esc>')

-- Move codeblocks when in visual mode
-- vim.keymap.set('v', '<S-J>', ":m '>+1<CR>gv=gv", { silent = true })
-- vim.keymap.set('v', '<S-K>', ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set('v', 'x', '"_d', { silent = true })
vim.keymap.set('v', 'p', 'P')
vim.keymap.set('v', 'P', 'p')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Behöver inte riktigt det här, overkill
-- -- Enable diagnostics automatically for all buffers
-- vim.api.nvim_create_autocmd('BufEnter', {
--   callback = function()
--     print(vim.diagnostic.is_enabled())
--     if not vim.diagnostic.is_enabled() then
--       vim.diagnostic.enable()
--     end
--   end,
-- })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Yoinked from HermanKassler to change cd
vim.keymap.set('n', '<leader>cd', '<cmd>cd %:p:h<CR><cmd>pwd<cr>', { desc = '[C][D] to directory of open file' })

-- Remove default vim.lsp kebinds which are already implemented with telescope keybinds.
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'gra')
