return {
  -- OPTIONAL: The community replacement for downloading extra parsers.
  {
    'arborist-ts/arborist.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    lazy = true,
    opts = {
      -- Switch to true maybe sometime in the future when wasmtime is used
      -- and nvim can be compiled with it.
      prefer_wasm = false,
      install_popular = false,
      update_cadence = 'weekly',
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    lazy = true,
    dependencies = { 'arborist-ts/arborist.nvim' },
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
