---@class MdpViewBackend A Markdown preview backend. This can be implemented by anything capable of rendering terminal output.
---@field new fun(source_buf:number, source_win:number, opts:table|nil) Create a new preview model; you can override default config with the `opts` parameter.
---@field destroy fun(buf:number) Close and destroy a preview model

local function get_backend(opts)
  local backend_name = vim.tbl_get(opts or {}, 'backend') or require('mdpreview.config').renderer.backend
  local ok, backend = pcall(require, string.format('mdpreview.views.%s', backend_name))
  if not ok then
    vim.notify(string.format('%s is not a valid renderer backend.', backend_name))
    return nil
  end

  return backend --[[@as MdpViewBackend]]
end

---@type MdpViewBackend
local M = {} ---@diagnostic disable-line

function M.new(source_buf, source_win, renderer_opts)
  local backend = get_backend(renderer_opts)
  if backend then
    backend.new(source_buf, source_win, vim.tbl_get(renderer_opts or {}, 'opts'))
  end
end

function M.destroy(buf)
  local backend = get_backend()
  if backend then
    backend.destroy(buf)
  end
end

return M
