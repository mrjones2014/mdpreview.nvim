-- as more backends are added, add as a union type on these two types
---@alias MdpBackendConfig MdpBufferViewOpts
---@alias MdpBackendName 'buffer'

---@class MdpConfig
local config = {
  cli_args = {
    'glow',
    -- glow assumes you want no colors if not run in a TTY
    '-s',
    'dark',
    -- let nvim handle word wrapping, disable glow word wrap
    '-w',
    '1',
    -- don't unexpectedly make network connections
    '--local',
  },
  filetypes = { 'markdown', 'markdown.pandoc', 'markdown.gfm' },
  renderer = {
    ---@type MdpBackendName
    backend = 'buffer',
    ---@type MdpBackendConfig
    opts = {
      winnr = function()
        vim.cmd('vsp')
        return vim.api.nvim_get_current_win()
      end,
      win_opts = {
        signcolumn = 'no',
        number = false,
        concealcursor = 'niv',
        wrap = true,
        linebreak = true,
      },
    },
  },
}

local M = setmetatable({}, {
  __index = function(_, key)
    return config[key]
  end,
  __newindex = function(_, key, value)
    config[key] = value
  end,
})

function M.setup(new_config)
  config = vim.tbl_deep_extend('force', config, new_config or {})

  -- normalize to table
  if type(config.cli_args) ~= 'table' then
    config.cli_args = { config.cli_args }
  end
end

return M
