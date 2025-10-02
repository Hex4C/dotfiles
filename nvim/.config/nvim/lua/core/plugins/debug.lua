-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Own debuggers
    -- 'mfussenegger/nvim-dap-python',
  },
  -- cmd = { 'DapClearBreakpoints', 'DapNew', 'DapInstall', 'DapUninstall', 'DapToggleBreakpoint', 'DapShowLog' },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    vim.keymap.set('n', '<F1>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F3>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F4>', dap.step_out, { desc = 'Debug: Step Out' })
    -- vim.keymap.set('n', '<F5>', dap.step_back)
    vim.keymap.set('n', '<F6>', dap.terminate, { desc = 'Debug: Terminate' })

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
    vim.keymap.set('n', '<space>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<space>gb', dap.run_to_cursor, { desc = 'Debug: Run to cursor' })

    ---@diagnostic disable-next-line: missing-parameter
    require('nvim-dap-virtual-text').setup()

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = {
        'codelldb',
        'debugpy',
        'Delve',
      },
      handlers = {},
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Own custom deboggers...
    -- Need to be added as dependencies earlier in the file...
    -- require('dap-python').setup 'python3'
  end,
}
