local M = {}

local repl_buf = nil
local repl_win = nil

-------------------------------------------------------------------
-- Create / show the REPL
-------------------------------------------------------------------
function M.open_repl()
  -- Already open?
  if repl_win and vim.api.nvim_win_is_valid(repl_win) then
    vim.api.nvim_set_current_win(repl_win)
    return
  end

  -- Create buffer if needed
  if not repl_buf or not vim.api.nvim_buf_is_valid(repl_buf) then
    repl_buf = vim.api.nvim_create_buf(false, true)
  end

  -- Open floating window
  repl_win = vim.api.nvim_open_win(repl_buf, true, {
    relative = 'editor',
    width = math.floor(vim.o.columns * 0.80),
    height = math.floor(vim.o.lines * 0.30),
    row = math.floor(vim.o.lines * 0.65),
    col = math.floor(vim.o.columns * 0.10),
    border = 'rounded',
  })

  -- Only call termopen if buffer does not already have a terminal
  if vim.b[repl_buf].terminal_job_id == nil then
    vim.fn.termopen('uv run --env-file .env python', {
      on_exit = function()
        repl_buf = nil
        repl_win = nil
      end,
    })
  end
end

-------------------------------------------------------------------
-- Toggle the REPL window (keeps running in background)
-------------------------------------------------------------------
function M.toggle_repl()
  if repl_win and vim.api.nvim_win_is_valid(repl_win) then
    vim.api.nvim_win_close(repl_win, true)
    repl_win = nil
  else
    M.open_repl()
  end
end

-------------------------------------------------------------------
-- Internal: send text to repl
-------------------------------------------------------------------
local function send_to_repl(text)
  if not repl_buf or not vim.api.nvim_buf_is_valid(repl_buf) then
    M.open_repl()
  end

  -- Ensure there's a terminal channel
  local chans = vim.api.nvim_buf_get_var(repl_buf, 'terminal_job_id')
  if not chans then
    M.open_repl()
  end

  vim.api.nvim_chan_send(vim.b[repl_buf].terminal_job_id, text .. '\n')
end

-------------------------------------------------------------------
-- Send current line
-------------------------------------------------------------------
function M.send_line()
  local line = vim.api.nvim_get_current_line()
  send_to_repl(line)
end

-------------------------------------------------------------------
-- Send visual selection
-------------------------------------------------------------------
function M.send_selection()
  -- Save current register
  local save_reg = vim.fn.getreg '"'
  local save_regtype = vim.fn.getregtype '"'

  -- Reselect the visual selection
  vim.cmd 'normal! "vy'

  -- Get selection text (multiple lines preserved)
  local text = vim.fn.getreg '"'

  -- Restore original register
  vim.fn.setreg('"', save_reg, save_regtype)

  send_to_repl(text)
end

-------------------------------------------------------------------
-- Send whole file
-------------------------------------------------------------------
function M.send_file()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  send_to_repl(table.concat(lines, '\n'))
end

-------------------------------------------------------------------
-- Inspect variable (pretty print in REPL)
-------------------------------------------------------------------
function M.inspect(var)
  send_to_repl(string.format('import pprint; pprint.pprint(%s)', var))
end

-------------------------------------------------------------------
-- Open DataFrame in VisiData
-------------------------------------------------------------------
function M.view_df(varname)
  -- Send command to open DataFrame in VisiData
  local cmd = table.concat({
    'import visidata',
    string.format('visidata.view_pandas(%s)', varname),
  }, '; ')

  send_to_repl(cmd)
end

-------------------------------------------------------------------
-- For debugging: direct eval
-------------------------------------------------------------------
function M.exec(text)
  send_to_repl(text)
end

return M
