local Qfheight = require "qfheight.main"
local qfh = Qfheight.new()

---@class qfheight
---@field setup fun(opts: qfheight.main.Options): nil
---@field enable fun(): nil
---@field disable fun(): nil
---@field set fun(): nil

---@type qfheight
return setmetatable({}, {
  __index = function(_, method)
    return function(...)
      local args = { ... }
      local f = qfh[method]
      if f then
        f(qfh, unpack(args))
      else
        f:warn("unknown method: " .. method)
      end
    end
  end,
})
