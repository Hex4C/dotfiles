return { -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        -- `friendly-snippets` contains a variety of premade snippets.
        --    See the README about individual language/framework/plugin snippets:
        --    https://github.com/rafamadriz/friendly-snippets
        -- {
        --   'rafamadriz/friendly-snippets',
        --   config = function()
        --     require('luasnip.loaders.from_vscode').lazy_load()
        --   end,
        -- },
      },
    },
    'saadparwaiz1/cmp_luasnip',
    -- Adds other completion capabilities.
    --  nvim-cmp does not ship with all sources by default. They are split
    --  into multiple repos for maintenance purposes.
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
  },
  config = function()
    -- See `:help cmp`
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    local lsp_icons = {
      Array = ' ',
      Boolean = '󰨙 ',
      Class = ' ',
      Color = ' ',
      Constant = '󰏿 ',
      Constructor = ' ',
      Enum = ' ',
      EnumMember = ' ',
      Event = ' ',
      Field = ' ',
      File = ' ',
      Folder = ' ',
      Function = '󰊕 ',
      Interface = ' ',
      Key = ' ',
      Keyword = ' ',
      Method = '󰊕 ',
      Module = ' ',
      Namespace = '󰦮 ',
      Null = ' ',
      Number = '󰎠 ',
      Object = ' ',
      Operator = ' ',
      Package = ' ',
      Property = ' ',
      Reference = ' ',
      Snippet = ' ',
      String = ' ',
      Struct = '󰆼 ',
      Text = ' ',
      TypeParameter = ' ',
      Unit = ' ',
      Value = ' ',
      Variable = '󰀫 ',
    }

    luasnip.config.setup {}

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = { completeopt = 'menu,menuone,noinsert' },

      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert {
        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window [b]ack / [f]orward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Accept ([y]es) the completion.
        -- See more examples here:
        --
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
        --
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        -- NOTE: Different completion alternatives
        --
        -- ['<C-y>'] = cmp.mapping.confirm { select = true },
        -- ['<Tab>'] = cmp.mapping.confirm { select = true },
        ['<CR>'] = cmp.mapping.confirm { select = true },
        --
        -- ['<CR>'] = cmp.mapping {
        --   i = function(fallback)
        --     if cmp.visible() and cmp.get_active_entry() then
        --       cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        --     else
        --       fallback()
        --     end
        --   end,
        --   s = cmp.mapping.confirm { select = true },
        --   c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
        -- },

        -- If you prefer more traditional completion keymaps,
        -- you can uncomment the following lines
        --['<CR>'] = cmp.mapping.confirm { select = true },
        --['<Tab>'] = cmp.mapping.select_next_item(),
        --['<S-Tab>'] = cmp.mapping.select_prev_item(),

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        -- ['<C-Space>'] = cmp.mapping.complete {},
        --
        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      sources = {
        {
          name = 'lazydev',
          -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
          group_index = 0,
        },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
      },
      -- NOTE: Border if you'd like it later
      --
      window = {
        -- completion = cmp.config.window.bordered(),
        -- NOTE: Only enable documentation border and not for completion aswell
        documentation = cmp.config.window.bordered {
          border = 'rounded',
          -- Either comment out the row under for no colors or make the Floatbg the same as normal float. Border none works as well.
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
          -- max_height = 15,
        },
      },
      formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        expandable_indicator = false, -- This will show when an item is expandable
        -- NOTE: entry instead of _ if I want the expandable entry...
        format = function(_, item)
          -- Add icons to LSP kinds
          if lsp_icons[item.kind] then
            item.kind = lsp_icons[item.kind] .. item.kind
          end

          -- Define truncation widths for 'abbr' and 'menu'
          local widths = {
            abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
            menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
          }

          -- Truncate the 'abbr' and 'menu' fields if they exceed the width
          for key, width in pairs(widths) do
            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
              item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. '…'
            end
          end

          -- Handle expandable indicator (if using snippets or other expandable items)
          -- if entry.completion_item and entry.completion_item.insertTextFormat == 2 then
          --   item.kind = item.kind .. ' ➤'
          -- end

          return item
        end,
      },
    }
  end,
}
