vim.api.nvim_create_user_command('Mdpreview', function(opts)
  if opts and opts.bang then
    require('mdpreview').stop_preview()
  else
    require('mdpreview').preview()
  end
end, {
  nargs = '*',
  bang = true,
})

vim.api.nvim_create_user_command('MdpreviewCurrent', function(opts)
  if opts and opts.bang then
    require('mdpreview').stop_preview()
  else
    require('mdpreview').preview({
      backend = 'buffer',
      opts = { winnr = 0 },
    })
  end
end, {
  nargs = '*',
  bang = true,
})
