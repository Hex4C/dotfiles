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
-- PERF: Pref 
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

-- Keymaps
require 'keymaps'

-- Install the Lazy plugin manager
require 'lazy-bootstrap'

-- Install lazy plugins
require 'lazy-plugins'

-- Add plugin setups
require 'plugin-setups'
