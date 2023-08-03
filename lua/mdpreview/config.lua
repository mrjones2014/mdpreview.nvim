return {
  cli_path = 'glow',
  create_preview_win = function()
    vim.cmd('vsp')
    return vim.api.nvim_get_current_win()
  end,
  filetypes = { 'markdown', 'markdown.pandoc', 'markdown.gfm' },
}
