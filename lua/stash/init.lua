local M = {}

function M.setup(opts)
   opts = opts or {}

   vim.keymap.set("n", "<Leader>h", function()
     print(vim.api.nvim_get_current_buf())
   end)
end

return M
