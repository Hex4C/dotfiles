return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    local toggle_opts = {
      title = ' Harpoon ',
      border = 'rounded',
      title_pos = 'center',
      ui_width_ratio = 0.40,
    }

    -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = '[a]dd to Harpoon' })

    vim.keymap.set('n', '<leader>g', function()
      harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
    end, { desc = '[G] Harpoon quick menu' })

    -- NOTE: telescope window but Harpoon window is more minimalistic
    --
    -- local conf = require('telescope.config').values
    -- local function toggle_telescope(harpoon_files)
    --   local file_paths = {}
    --   for _, item in ipairs(harpoon_files.items) do
    --     table.insert(file_paths, item.value)
    --   end
    --
    --   require('telescope.pickers')
    --     .new({}, {
    --       prompt_title = 'Harpoon',
    --       finder = require('telescope.finders').new_table {
    --         results = file_paths,
    --       },
    --       previewer = conf.file_previewer {},
    --       sorter = conf.generic_sorter {},
    --     })
    --     :find()
    -- end

    -- vim.keymap.set('n', '<C-e>', function()
    --   toggle_telescope(harpoon:list())
    -- end, { desc = 'Open harpoon window' })

    vim.keymap.set('n', '<m-a>', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<m-s>', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<m-d>', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<m-f>', function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<m-S-P>', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<m-S-N>', function()
      harpoon:list():next()
    end)
  end,
}
