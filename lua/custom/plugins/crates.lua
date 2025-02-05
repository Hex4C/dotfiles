return {
  'saecki/crates.nvim',
  tag = 'stable',
  config = function()
    local crates = require 'crates'
    crates.setup {}

    vim.keymap.set('n', '<leader>ct', crates.toggle, { desc = '[c]rates [t]oggle', silent = true })
    vim.keymap.set('n', '<leader>cr', crates.reload, { desc = '[c]rates [r]eload', silent = true })
    vim.keymap.set('n', '<leader>cc', crates.show_crate_popup, { desc = '[c]rates show [c]rate info', silent = true })
    vim.keymap.set('n', '<leader>cf', crates.show_features_popup, { desc = '[c]rates show [f]eatures', silent = true })
    vim.keymap.set('n', '<leader>cv', crates.show_versions_popup, { desc = '[c]rates show [v]ersions', silent = true })
    vim.keymap.set('n', '<leader>cd', crates.show_dependencies_popup, { desc = '[c]rates show [d]ependencies', silent = true })
  end,
}
