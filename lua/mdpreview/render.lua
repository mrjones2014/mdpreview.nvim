local Config = require('mdpreview.config')

local M = {}

function M.render(buf, on_done)
  buf = buf or 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local job_id = vim.fn.jobstart(Config.cli_args, {
    rpc = false,
    stdin = 'pipe',
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if on_done then
        on_done(data)
      end
    end,
    on_stderr = function(_, data)
      local err_lines = table.concat(data, '\n')
      if #err_lines > 0 then
        vim.notify(err_lines, vim.log.levels.ERROR)
      end
      on_done(nil)
    end,
  })
  if job_id < 1 then
    vim.notify('Failed to start CLI job', vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(job_id, lines)
  vim.fn.chanclose(job_id, 'stdin')
end

return M
