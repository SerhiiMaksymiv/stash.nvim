local M = {}

M.Stack = function ()
  return setmetatable({
    _stack = {},
    count = 0,
    nonce = 0,
    is_stash = false,

    size = function(self)
      return self.count
    end,

    get_nonce = function(self)
      return self.nonce
    end,

    is_move_stash = function(self)
      return self.is_stash
    end,

    move_stash_lock = function(self)
      self.is_stash = true
    end,

    move_stash_unlock = function(self)
      self.is_stash = false
    end,

    get_current = function(self)
      for i = 1, self.count do
        local item = rawget(self._stack, i)
        if item.current then
          return item
        end
      end
    end,

    set_current = function(self, value)
      for i = 1, self.count do
        local item = rawget(self._stack, i)
        if item.name == value.name then
          item.current = true
          break
        end
      end
    end,

    indexOf = function(self, value)
      for i, v in ipairs(self._stack) do
        if v == value then
          return i
        end
      end
      return nil
    end,

    indexOfName = function(self, name)
      for i, v in ipairs(self._stack) do
        if v.name == name then
          return i
        end
      end
      return nil
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

    move_down_stash = function(self)
      return rawget(self._stack, self.count)
    end,

    move_up_stash = function(self)
    end,

    shift = function(self)
      self.count = self.count - 1
      return table.remove(self._stack, 1)
    end,

    get_by_index = function(self, index)
      return rawget(self._stack, index)
    end,

    remove = function(self, name)
      for i = 1, self.count do
        local val = rawget(self._stack, i)
        if val.name == name then
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
      print(string.rep("=", 10))
      print(vim.inspect(self._stack))
      print(string.rep("=", 20))
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

return M
