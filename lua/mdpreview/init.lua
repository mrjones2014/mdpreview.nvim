local Config = require('mdpreview.config')
local Views = require('mdpreview.views')

local M = {}

function M.setup(user_cfg)
  Config = vim.tbl_deep_extend('force', Config, user_cfg)
end

---Start a preview, optionally passing overrides for renderer opts
---@param renderer_opts table|nil
function M.preview(renderer_opts)
  if vim.fn.executable(Config.cli_path) == 0 then
    vim.notify(string.format('%s not installed', Config.cli_path), vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.ft
  if #vim.tbl_filter(function(filetype)
        return filetype == ft
      end, Config.filetypes) == 0 then
    vim.notify('mdpreview only works on markdown files', vim.log.levels.ERROR)
    return
  end

  Views.new(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win(), renderer_opts)
end

function M.stop_preview()
  Views.destroy(vim.api.nvim_get_current_buf())
end

return M
