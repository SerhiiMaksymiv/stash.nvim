local M = {}

M.Stack = function ()
  return setmetatable({
    _stack = {},
    count = 0,

    size = function(self)
      return self.count
    end,

    clear = function(self)
      self._stack = {}
      self.count = 0
    end,

    push = function(self, obj)
      self.count = self.count + 1
      rawset(self._stack, self.count, obj)
    end,

    pop = function(self)
      self.count = self.count - 1
      return table.remove(self._stack)
    end,

    peak = function(self)
      return rawget(self._stack, self.count)
    end,

    shift = function(self)
      self.count = self.count - 1
      return table.remove(self._stack, 1)
    end,

    remove = function(self, value)
      for i = 2, self.count do
        local val = rawget(self._stack, i)
        if val == value then
          table.remove(self._stack, i)
          self.count = self.count - 1
          break
        end
      end
    end,

    each = function(self, callback)
      for i = 1, self.count do
        callback(rawget(self._stack, i), i)
      end
    end,

    print = function(self)
      for i = 1, self.count do
        print(rawget(self._stack, i))
      end
    end,

    map = function(self, callback)
      for i = 1, self.count do
        rawset(self._stack, i, callback(rawget(self._stack, i)))
      end
    end,

    is_present = function(self, value)
      local r = false

      for i = 1, self.count do
        local val = rawget(self._stack, i)
        if val == value then
          r = true
          break
        end
      end

      return r
    end,
  }, {
    __index = function(self, index)
      return rawget(self._stack, index)
    end,
  })
end

M.setup = function(opts)
  local stack = M.Stack()

  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      if stack:size() < 50 then
        if buf_name ~= '' and not string.find(buf_name, "NvimTree") then
          stack:remove(buf_name)
          stack:push(buf_name)
        end
      else
        print('Stack size reached its limit: ' .. stack:size())
      end
    end,
  })

  vim.keymap.set('n', '<leader>b', function()
    stack:pop()
    vim.cmd.edit(stack:peak())
  end)

  vim.keymap.set('n', '<leader>gb', function()
    stack:print()
  end)

end

return M

