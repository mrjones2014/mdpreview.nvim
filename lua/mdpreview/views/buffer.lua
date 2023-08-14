local Config = require('mdpreview.config')
local Renderer = require('mdpreview.render')

---@class MdpBufferView
---@field source_buf number source Markdown buffer
---@field dest_buf number destination buffer being rendered into
---@field source_win number source window
---@field source_win_opts table
---@field dest_win number destination window being rendered into
---@field autocmd_id number ID of the autocmd that updates the view

---@class MdpBufferViewOpts
---@field winnr number|function
---@field win_opts table

---@type MdpBufferView[]
local views = {}

---Get the view session
---@param buf number|nil source or destination buffer ID
---@return MdpBufferView|nil
local function get(buf)
  buf = buf or vim.api.nvim_win_get_buf(0)
  for _, view in pairs(views) do
    if view.source_buf == buf or view.dest_buf == buf then
      return view
    end
  end

  return nil
end

---@param win number
---@param opts MdpBufferViewOpts
---@return table
local function build_win_opts_restore_table(win, opts)
  opts = opts or {}
  local result = {}
  for key, _ in pairs(opts.win_opts or {}) do
    result[key] = vim.wo[win][key]
  end
  return result
end

---@param win number
---@param opts MdpBufferViewOpts
local function set_win_opts(win, opts)
  opts = opts or {}
  for key, value in pairs(opts.win_opts or {}) do
    vim.wo[win][key] = value
  end
end

local M = {}

---Create a session
---@param source_buf number
---@param source_win number cursor will be moved back to this window after setting up the view
---@param opts MdpBufferViewOpts|nil override default options
function M.new(source_buf, source_win, opts)
  opts = vim.tbl_deep_extend('force', {}, Config.renderer.opts, opts) --[[@as MdpBufferViewOpts]]
  local source_win_opts = build_win_opts_restore_table(source_win, opts)
  local dest_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(dest_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(dest_buf, 'modifiable', false)

  -- keymaps
  local keymaps_opts = { noremap = true, silent = true, buffer = dest_buf }
  vim.keymap.set('n', 'q', require('mdpreview').stop_preview, keymaps_opts)
  vim.keymap.set('n', '<Esc>', require('mdpreview').stop_preview, keymaps_opts)

  if type(opts.winnr) ~= 'function' and type(opts.winnr) ~= 'number' then
    opts.winnr = Config.renderer.opts.winnr
  end

  -- if it's a function, call it
  if type(opts.winnr) == 'function' then
    opts.winnr = opts.winnr()
  end

  if opts.winnr == 0 then
    opts.winnr = vim.api.nvim_get_current_win()
  end
  -- fallback
  if
    not opts.winnr or not vim.api.nvim_win_is_valid(opts.winnr --[[@as number]])
  then
    vim.cmd('vsp')
    opts.winnr = vim.api.nvim_get_current_win()
  end

  local render_callback = function()
    local lines = vim.api.nvim_buf_get_lines(source_buf, 0, vim.api.nvim_buf_line_count(0), false)
    if vim.tbl_isempty(lines) then
      vim.notify('buffer is empty', vim.log.levels.ERROR)
      return
    end
    Renderer.render(source_buf, function(data)
      if data and #data > 0 then
        vim.bo[dest_buf].modifiable = true
        vim.api.nvim_buf_set_lines(dest_buf, 0, -1, false, data)
        vim.bo[dest_buf].modifiable = false
      end
    end)
  end
  render_callback()
  local autocmd_id = vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    callback = render_callback,
    buffer = source_buf,
  })

  vim.api.nvim_win_set_buf(opts.winnr --[[@as number]], dest_buf)
  -- for some reason it only works to set the filetype after showing the buffer
  vim.api.nvim_buf_set_option(dest_buf, 'filetype', 'terminal')

  vim.schedule(function()
    set_win_opts(opts.winnr --[[@as number]], opts)
  end)

  vim.api.nvim_set_current_win(source_win)

  vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    callback = function()
      pcall(M.destroy, source_buf)
    end,
    buffer = source_buf,
    once = true,
  })

  views[source_buf] = {
    source_buf = source_buf,
    source_win = source_win,
    source_win_opts = source_win_opts,
    dest_buf = dest_buf,
    dest_win = opts.winnr, ---@diagnostic disable-line
    autocmd_id = autocmd_id,
  }
  vim.b[dest_buf].mdpreview_session = views[source_buf]
end

function M.destroy(buf)
  local session = get(buf)
  if session then
    if session.dest_win ~= session.source_win then
      pcall(vim.api.nvim_win_close, session.dest_win, true)
    else
      vim.schedule(function()
        for key, value in pairs(session.source_win_opts) do
          vim.wo[session.source_win][key] = value
        end
      end)
    end
    pcall(vim.api.nvim_buf_delete, session.dest_buf, { force = true })
    pcall(vim.api.nvim_del_autocmd, session.autocmd_id)
    views[session.source_buf] = nil
  end
end

return M
