return {
  name = 'repltools',
  dir = vim.fn.stdpath 'config' .. '/lua/repltools',
  dependencies = {},
  config = function()
    local repl = require 'repltools'

    -------------------------------------------------------------------
    -- Commands
    -------------------------------------------------------------------
    vim.api.nvim_create_user_command('ReplOpen', function()
      repl.open_repl()
    end, {})

    vim.api.nvim_create_user_command('ReplToggle', function()
      repl.toggle_repl()
    end, {})

    vim.api.nvim_create_user_command('ReplSendLine', function()
      repl.send_line()
    end, {})

    vim.api.nvim_create_user_command('ReplSend', function()
      repl.send_selection()
    end, { range = true })

    vim.api.nvim_create_user_command('ReplSendFile', function()
      repl.send_file()
    end, {})

    vim.api.nvim_create_user_command('ReplInspect', function(opts)
      repl.inspect(opts.args)
    end, { nargs = 1 })

    vim.api.nvim_create_user_command('ReplVD', function(opts)
      repl.view_df(opts.args)
    end, { nargs = 1 })

    -------------------------------------------------------------------
    -- Keymaps
    -------------------------------------------------------------------
    local map = vim.keymap.set
    local opts = { silent = true, noremap = true }

    map('n', '<leader>ro', repl.open_repl, { desc = 'Open REPL' })
    map('n', '<leader>rr', repl.toggle_repl, { desc = 'Toggle REPL window' })
    map('n', '<leader>rl', repl.send_line, { desc = 'Send line to REPL' })
    map('v', '<leader>rs', repl.send_selection, { desc = 'Send selection' })
    map('n', '<leader>rF', repl.send_file, { desc = 'Send entire file' })

    map('n', '<leader>ri', function()
      vim.ui.input({ prompt = 'Inspect variable: ' }, function(var)
        if var then
          repl.inspect(var)
        end
      end)
    end, { desc = 'Inspect variable' })

    map('n', '<leader>rd', function()
      vim.ui.input({ prompt = 'DataFrame variable: ' }, function(var)
        if var then
          repl.view_df(var)
        end
      end)
    end, { desc = 'View DataFrame in VisiData' })
  end,
}
