return {

  -- TODO:
  -- Rewrite treesitter to use the main branch instead of the master branch.
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
    config = function()
      local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python', 'rust', 'go', 'regex' }
      require('nvim-treesitter').install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          -- check if parser exists and load it
          if not vim.treesitter.language.add(language) then return end
          -- enables syntax highlighting and other treesitter features
          vim.treesitter.start(buf, language)

          -- enables treesitter based folds
          -- for more info on folds see `:help folds`
          -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- vim.wo.foldmethod = 'expr'

          -- enables treesitter based indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  -- { -- Highlight, edit, and navigate code
  --   'nvim-treesitter/nvim-treesitter',
  --   build = ':TSUpdate',
  --   opts = {
  --     ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python' },
  --     -- Autoinstall languages that are not installed
  --     auto_install = false,
  --     highlight = {
  --       enable = true,
  --       -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
  --       --  If you are experiencing weird indenting issues, add the language to
  --       --  the list of additional_vim_regex_highlighting and disabled languages for indent.
  --       additional_vim_regex_highlighting = { 'ruby' },
  --     },
  --     indent = { enable = true, disable = { 'ruby' } },
  --   },
  --   config = function(_, opts)
  --     -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  --
  --     ---@diagnostic disable-next-line: missing-fields
  --     require('nvim-treesitter.configs').setup(opts)
  --
  --     -- There are additional nvim-treesitter modules that you can use to interact
  --     -- with nvim-treesitter. You should go explore a few and see what interests you:
  --     --
  --     --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --     --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --     --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  --   end,
  -- },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
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
