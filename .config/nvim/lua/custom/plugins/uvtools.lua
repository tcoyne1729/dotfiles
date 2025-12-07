return {
  name = 'uvtools',
  dir = vim.fn.stdpath 'config' .. '/lua/uvtools',
  dependencies = {
    'folke/snacks.nvim',
  },
  config = function()
    local uvtools = require 'uvtools'
    local Input = require 'snacks.input'

    -- UvAdd
    vim.api.nvim_create_user_command('UvAdd', function()
      Input({ prompt = 'Package to add:' }, function(pkg)
        Input({ prompt = 'Dev dependency? (y/n):' }, function(dev)
          uvtools.add_package(pkg, dev == 'y')
        end)
      end)
    end, {})

    -- UvRemove
    vim.api.nvim_create_user_command('UvRemove', function()
      Input({ prompt = 'Package to remove:' }, function(pkg)
        uvtools.remove_package(pkg)
      end)
    end, {})

    -- UvRun
    vim.api.nvim_create_user_command('UvRun', function()
      uvtools.run_current_file()
    end, {})

    -- UvSetup
    vim.api.nvim_create_user_command('UvSetup', function()
      uvtools.setup_project()
    end, {})

    -- keymaps

    local map = vim.keymap.set

    map('n', '<leader>ua', '<cmd>UvAdd<cr>', { desc = 'UV Add Package' })
    map('n', '<leader>ur', '<cmd>UvRemove<cr>', { desc = 'UV Remove Package' })
    map('n', '<leader>uf', '<cmd>UvRun<cr>', { desc = 'UV Run Current File' })
    map('n', '<leader>us', '<cmd>UvSetup<cr>', { desc = 'UV Setup Project' })
  end,
}
