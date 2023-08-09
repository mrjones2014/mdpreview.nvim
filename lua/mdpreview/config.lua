return {
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
    backend = 'buffer',
    opts = {
      create_preview_win = function()
        vim.cmd('vsp')
        return vim.api.nvim_get_current_win()
      end,
    },
  },
}
