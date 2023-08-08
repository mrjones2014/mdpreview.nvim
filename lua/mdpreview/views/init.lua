---@class MdpViewBackend A Markdown preview backend. This can be implemented by anything capable of rendering terminal output.
---@field new fun(source_buf:number, source_win:number) Create a new preview model
---@field destroy fun(buf:number) Close and destroy a preview model

local function get_backend()
  local backend_name = require('mdpreview.config').renderer.backend
  local ok, backend = pcall(require, string.format('mdpreview.views.%s', backend_name))
  if not ok then
    vim.notify(string.format('%s is not a valid renderer backend.', backend_name))
    return nil
  end

  return backend --[[@as MdpViewBackend]]
end

---@type MdpViewBackend
local M = {} ---@diagnostic disable-line

function M.new(source_buf, source_win)
  local backend = get_backend()
  if backend then
    backend.new(source_buf, source_win)
  end
end

function M.destroy(buf)
  local backend = get_backend()
  if backend then
    backend.destroy(buf)
  end
end

return M
