vim.api.nvim_create_user_command('Glowy', function(opts)
  if opts and opts.bang then
    require('glowy').stop_preview()
  else
    require('glowy').preview()
  end
end, {
  complete = 'file',
  nargs = '*',
  bang = true,
})
