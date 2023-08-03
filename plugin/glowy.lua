vim.api.nvim_create_user_command('Mdpreview', function(opts)
  if opts and opts.bang then
    require('mdpreview').stop_preview()
  else
    require('mdpreview').preview()
  end
end, {
  complete = 'file',
  nargs = '*',
  bang = true,
})
