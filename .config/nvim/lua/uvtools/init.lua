local M = {}

--- Helper to open the quickfix list if it's not already open.
local function open_quickfix()
  if vim.fn.empty(vim.fn.getqflist()) == 0 then
    vim.cmd 'copen'
  end
end

local function run_cmd(cmd)
  local output = {}
  local errors = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(output, { text = line })
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          -- Use 'E' for error/warning severity in quickfix list
          table.insert(errors, { text = line, type = 'E' })
        end
      end
    end,
    on_exit = function(_, code)
      local all_messages = {}
      local status_msg

      if code ~= 0 then
        -- Job failed, prioritize error messages
        vim.notify('UV command failed (code: ' .. code .. '). See quickfix list.', vim.log.levels.ERROR)
        status_msg = '❌ UV Command Failed (code: ' .. code .. ')'
        all_messages = errors
      else
        -- Job succeeded, show output messages
        vim.notify('UV command finished successfully. See quickfix list.', vim.log.levels.INFO)
        status_msg = '✅ UV Command Succeeded'
        all_messages = output
      end

      -- Add a header to the quickfix list
      table.insert(all_messages, 1, { text = status_msg, type = 'I' })

      -- Set the quickfix list and open the window
      -- vim.fn.setqflist(all_messages, ' ', { title = 'UV Tools Output: ' .. table.concat(cmd, ' ') })
      vim.fn.setqflist({}, ' ', {
        items = all_messages, -- Your list of entries goes here
        title = 'UV Tools Output: ' .. table.concat(cmd, ' '),
      })
      open_quickfix()
    end,
  })
end

function M.add_package(pkg, dev)
  local flag_str = '--dev'
  local flag = dev and flag_str or ''
  if not pkg or pkg == '' then
    vim.notify('no pkg provided to install. skipping...', 'info')
  elseif flag == flag_str then
    run_cmd { 'uv', 'add', flag_str, pkg }
  else
    run_cmd { 'uv', 'add', pkg }
  end
end

function M.remove_package(pkg)
  run_cmd { 'uv', 'remove', pkg }
end

function M.run_current_file()
  local file = vim.fn.expand '%'
  run_cmd { 'uv', 'run', '--env-file', '.env', 'python', file }
end

function M.setup_project()
  run_cmd { 'uv', 'init' }
  run_cmd { 'uv', 'add', '--dev', 'ruff', 'jupyter', 'visidata' }
end

return M
