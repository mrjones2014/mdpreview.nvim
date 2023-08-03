local Config = require('glowy.config')
local Views = require('glowy.views')

local M = {}

function M.setup(user_cfg)
  Config = vim.tbl_deep_extend('force', Config, user_cfg)
end

function M.preview()
  if vim.fn.executable('glow') == 0 then
    vim.notify('glow not installed', vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.ft
  if #vim.tbl_filter(function(filetype)
    return filetype == ft
  end, Config.filetypes) == 0 then
    vim.notify('glowy only works on markdown files', vim.log.levels.ERROR)
    return
  end

  Views.new(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win())
end

function M.stop_preview()
  Views.destroy(vim.api.nvim_get_current_buf())
end

return M
