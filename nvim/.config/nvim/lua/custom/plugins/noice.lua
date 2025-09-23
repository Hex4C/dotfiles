return {
  'folke/noice.nvim',
  event = 'VimEnter',
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    'rcarriga/nvim-notify',
  },
  config = function()
    -- NOTE: Potentially limit the size of notify view.

    -- math.floor((vim.o.columns * 4) / 10)
    -- math.floor((vim.o.lines * 3) / 10)
    -- ---@diagnostic disable-next-line: missing-fields
    -- require('notify').setup {
    --   max_width = 50,
    --   max_height = 10,
    -- }

    ---@diagnostic disable-next-line: missing-fields
    require('noice').setup {
      lsp = {
        -- This is to disable some weird spam sometimes, maybe enalbe if I want more notifications in the future
        diagnostics = false,
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          -- WARNING: Not sure if the line below works due to blink.cmp instead of nvim-cmp
          ['cmp.entry.get_documentation'] = true,
        },
        hover = {
          enabled = true,
          silent = true,
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = false, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_borde = false, -- add a border to hover docs and signature help
      },
    }
  end,
}
