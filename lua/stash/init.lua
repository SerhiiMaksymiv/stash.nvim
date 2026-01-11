local Stack = require'stash.stack'

local stack

local M = {}

function M.setup(user_config)
  user_config = user_config or {}

  stack = Stack.Stack()

  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      if not stack:is_move_stash() then
        stack:add_to_stash(buf_name)
      end
    end,
  })
end

function M.back()
  stack:move_stash_lock()
  stack:move_down_stash()
  stack:move_stash_unlock()
end

function M.forward()
  stack:move_stash_lock()
  stack:move_up_stash()
  stack:move_stash_unlock()
end

function M.reset()
  stack:print()
end

function M.print()
  stack:print()
end

return M
