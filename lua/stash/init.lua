local Stash = function ()
  return setmetatable({
    _stack = {},
    _count = 0,
    _current = nil,

    size = function(self)
      return self._count
    end,

    set_current = function(self, buf)
      self._current = buf
    end,

    get_current = function(self)
      return self._current
    end,

    clear = function(self)
      self._stack = {}
      self._count = 0
    end,

    push = function(self, obj)
      self._count = self._count + 1
      rawset(self._stack, self._count, obj)
    end,

    pop = function(self)
      self._count = self._count - 1
      return table.remove(self._stack)
    end,

    peak = function(self, index)
      if index then
        return rawget(self._stack, index)
      end
      return rawget(self._stack, self._count)
    end,

    shift = function(self)
      self._count = self._count - 1
      return table.remove(self._stack, 1)
    end,

    find = function(self, callback)
      for i = 1, self._count do
        local val = rawget(self._stack, i)
        if callback(val) then
          return rawget(self._stack, i)
        end
      end
    end,

    map = function(self, callback)
      for i = 1, self._count do
        rawset(self._stack, i, callback(rawget(self._stack, i)))
      end
    end,

    remove = function(self, value)
      for i = 1, self._count do
        local val = rawget(self._stack, i)
        if val == value then
          table.remove(self._stack, i)
          self._count = self._count - 1
          break
        end
      end
    end,

    print = function(self)
      print('=========================================')
      print('Current', vim.inspect(self._current))
      print('-----------------------------------------')
      print('Count', vim.inspect(self._count))
      print('-----------------------------------------')
      print('Stack', vim.inspect(self._stack))
      print('=========================================')
    end,

    is_present = function(self, value)
      local r = false

      for i = 1, self._count do
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

local stash = Stash()

function stash.setup(user_config)
  user_config = user_config or {}

  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)

      if buf_name ~= '' and not string.find(buf_name, "NvimTree") then
        local exist = stash:find(function (item)
          return item.name == buf_name
        end)

        if exist then
          stash:set_current(exist)
          return
        end

        local prev = stash:peak()
        local buf = {
          name = buf_name,
          next = nil,
          previous = prev and prev.name,
        }

        stash:set_current(buf)
        stash:push(buf)
      end
    end
  })
end

function stash.close()
  local prev = stash:pop()
  if prev.previous then
    vim.cmd.edit(prev.previous)
  else
    print('back: current is nil')
  end
end

function stash.back()
  local curr = stash:get_current()
  if curr and curr.previous then
    local prev = stash:find(function (item)
      return item.name == curr.previous
    end)
    prev.next = curr.name
    vim.cmd.edit(prev.name)
  else
    print('back: current is nil')
  end
end

function stash.forward()
  local curr = stash:get_current()
  if curr and curr.next then
    vim.cmd.edit(curr.next)
  else
    print('forward: current is nil')
  end
end

return stash

