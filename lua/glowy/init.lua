local config = {
  glow_path = 'glow',
  create_preview_win = function()
    vim.cmd('vsp')
    return vim.api.nvim_get_current_win()
  end,
  filetypes = { 'markdown', 'markdown.pandoc', 'markdown.gfm' },
}

local win, buf, job_id, autocmd_id

local function stop_job()
  if job_id == nil then
    return
  end
  vim.fn.jobstop(job_id)
end

local function update_preview(source_buf, dest_buf)
  return function()
    local lines = vim.api.nvim_buf_get_lines(source_buf, 0, vim.api.nvim_buf_line_count(0), false)
    if vim.tbl_isempty(lines) then
      vim.notify('buffer is empty', vim.log.levels.ERROR)
      return
    end
    job_id = vim.fn.jobstart({ config.glow_path, '-s', 'dark' }, {
      rpc = false,
      stdin = 'pipe',
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        vim.bo[dest_buf].modifiable = true
        vim.api.nvim_buf_set_lines(dest_buf, 0, -1, false, data)
        vim.bo[dest_buf].modifiable = false
      end,
      on_stderr = function(_, data)
        local err_lines = table.concat(data, '\n')
        if #lines > 0 then
          vim.notify(err_lines, vim.log.levels.ERROR)
        end
      end,
    })
    if job_id < 1 then
      vim.notify('Failed to start "glow" job', vim.log.levels.ERROR)
      return
    end

    vim.fn.chansend(job_id, lines)
    vim.fn.chanclose(job_id, 'stdin')
  end
end

local function stop_preview()
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
  end

  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
    buf = nil
  end

  if autocmd_id then
    pcall(vim.api.nvim_del_autocmd, autocmd_id)
  end
end

local function setup_preview(source_win, source_buf)
  -- create preview buffer and set local options
  buf = vim.api.nvim_create_buf(false, true)
  if not win or not vim.api.nvim_win_is_valid(win) then
    win = config.create_preview_win()
    -- fallback
    if not win or vim.api.nvim_win_is_valid(win) then
      vim.cmd('vsp')
      win = vim.api.nvim_get_current_win()
    end
  end
  vim.api.nvim_win_set_buf(win, buf)

  -- options
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'glowpreview')
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'terminal')
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(win, 'number', false)

  -- keymaps
  local keymaps_opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set('n', 'q', stop_preview, keymaps_opts)
  vim.keymap.set('n', '<Esc>', stop_preview, keymaps_opts)

  vim.api.nvim_set_current_win(source_win)
  local cb = update_preview(source_buf, buf)
  cb()
  autocmd_id = vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    callback = cb,
    buffer = source_buf,
  })
end

local M = {}

function M.setup(user_cfg)
  config = vim.tbl_deep_extend('force', config, user_cfg)
end

function M.preview()
  if vim.fn.executable('glow') == 0 then
    vim.notify('glow not installed', vim.log.levels.ERROR)
    return
  end

  local ft = vim.bo.ft
  if #vim.tbl_filter(function(filetype)
    return filetype == ft
  end, config.filetypes) == 0 then
    vim.notify('glowy only works on markdown files', vim.log.levels.ERROR)
    return
  end

  stop_job()

  setup_preview(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf())
end

function M.stop_preview()
  stop_preview()
end

return M
