local Config = require('mdpreview.config')
local Renderer = require('mdpreview.render')

---@class MdpBufferView
---@field source_buf number source Markdown buffer
---@field dest_buf number destination buffer being rendered into
---@field dest_win number destination window being rendered into
---@field autocmd_id number ID of the autocmd that updates the view

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

local M = {}

---Create a session
---@param source_buf number
---@param source_win number cursor will be moved back to this window after setting up the view
function M.new(source_buf, source_win)
  local dest_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(dest_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(dest_buf, 'modifiable', false)

  -- keymaps
  local keymaps_opts = { noremap = true, silent = true, buffer = dest_buf }
  vim.keymap.set('n', 'q', require('mdpreview').stop_preview, keymaps_opts)
  vim.keymap.set('n', '<Esc>', require('mdpreview').stop_preview, keymaps_opts)

  local dest_win = Config.renderer.opts.create_preview_win()
  -- fallback
  if not dest_win or not vim.api.nvim_win_is_valid(dest_win) then
    vim.cmd('vsp')
    dest_win = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_win_set_option(dest_win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(dest_win, 'number', false)

  local render_callback = Renderer.render_into_buf_callback(source_buf, dest_buf)
  render_callback()
  local autocmd_id = vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    callback = render_callback,
    buffer = source_buf,
  })

  vim.api.nvim_win_set_buf(dest_win, dest_buf)
  -- for some reason it only works to set the filetype after showing the buffer
  vim.api.nvim_buf_set_option(dest_buf, 'filetype', 'terminal')

  vim.api.nvim_set_current_win(source_win)

  vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    callback = function()
      M.destroy(source_buf)
    end,
    buffer = source_buf,
    once = true,
  })

  views[source_buf] = {
    source_buf = source_buf,
    dest_buf = dest_buf,
    dest_win = dest_win,
    autocmd_id = autocmd_id,
  }
end

function M.destroy(buf)
  local session = get(buf)
  if session then
    pcall(vim.api.nvim_win_close, session.dest_win, true)
    pcall(vim.api.nvim_buf_delete, session.dest_buf, { force = true })
    pcall(vim.api.nvim_del_autocmd, session.autocmd_id)
    views[session.source_buf] = nil
  end
end

return M
