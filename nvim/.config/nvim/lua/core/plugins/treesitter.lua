return {
  -- OPTIONAL: The community replacement for downloading extra parsers.
  -- {
  --   'arborist-ts/arborist.nvim',
  --   lazy = false,
  -- },

  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf = args.buf
          local filetype = args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          -- Start native treesitter highlighting safely
          pcall(vim.treesitter.start, buf, language)
        end,
      })

      require('treesitter-context').setup {
        enable = true,
        max_lines = 5,
        trim_scope = 'outer',
        patterns = {
          default = {
            'class',
            'function',
            'method',
          },
        },
        zindex = 20,
      }
    end,
  },
}
