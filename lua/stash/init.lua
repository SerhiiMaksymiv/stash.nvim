local Stack = require('stash.stack')

local stack

local M = {}

function M.setup(user_config)
  user_config = user_config or {}

  stack = Stack.Stack()

  local add_to_stash = function(buf_name)
    if stack:size() < 20 then
      if buf_name ~= '' and not string.find(buf_name, "NvimTree") then

        local item = stack:get_current()
        if item then
          item.current = false -- update current buffer
        end

        local top = {
          name = buf_name,
          current = true
        }

        if not stack:indexOfName(buf_name) then -- add new buffer to stack
          stack:push(top)
        else -- push existing buffer to top of stack
          stack:remove(buf_name)
          stack:push(top)
        end
      end
    else
      print('Stack size reached its limit: ' .. stack:size())
    end
  end

  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      if not stack:is_move_stash() then
        add_to_stash(buf_name)
      end
    end,
  })
end

function M.back()
  stack:move_stash_lock()
  local current = stack:get_current()
  local index = stack:indexOf(current)
  local prev = stack:get_by_index(index - 1)
  if prev then
    current.current = false
    stack:set_current(prev)
    vim.cmd.edit(prev.name)
  else
    vim.cmd.edit(vim.api.nvim_buf_get_name(0))
  end
  stack:move_stash_unlock()
end

function M.forward()
  stack:move_stash_lock()
  local current = stack:get_current()
  local index = stack:indexOf(current)
  local next = stack:get_by_index(index + 1)
  if next then
    current.current = false
    stack:set_current(next)
    vim.cmd.edit(next.name)
  else
    vim.cmd.edit(stack:peak())
  end
  stack:move_stash_unlock()
end

function M.print()
  stack:print()
end

return M
