--[[

=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   MSKOLDIS.NVIM    ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================

-- Folke Highlights...
-- PERF: Perf 
-- HACK: Lifehack :P
-- TODO: Something I should do...
-- NOTE: Yeah, note to be added
-- FIX:: Should be fixed asap
-- BUG:: Fungerar också...
-- WARNING: Varning, varning... 

--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Setting options
require 'options'
require 'keymaps'

-- Install the Lazy plugin manager
-- Install lazy plugins
-- Add plugin setups
require 'lazy-bootstrap'
require 'lazy-plugins'
require 'plugin-setups'

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    require 'diagnostic-config'
    require 'folds'
  end,
})
