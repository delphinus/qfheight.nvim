---@class qfheight.main.Qfheight
---@field default_options qfheight.main.Options
---@field opts qfheight.main.Options
---@field augroup integer
local Qfheight = {}

---@return qfheight.main.Qfheight
Qfheight.new = function()
  return setmetatable(
    { augroup = vim.api.nvim_create_augroup("qfheight", {}), default_options = { max = 10, min = 3 }, opts = {} },
    { __index = Qfheight }
  )
end

---@class qfheight.main.Options
---@field max integer
---@field min integer

---@param opts qfheight.main.Options
---@return nil
function Qfheight:setup(opts)
  self.opts = vim.tbl_extend("force", self.default_options, opts)
  self:enable()
end

---@return nil
function Qfheight:enable()
  self:disable()
  vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
    callback = function()
      if vim.opt.buftype:get() == "quickfix" then
        self:set()
      end
    end,
  })
end

---@return nil
function Qfheight:disable()
  vim.api.nvim_clear_autocmds { group = self.augroup }
end

function Qfheight:set()
  local i = 0
  local count = 0
  local last = vim.fn.line "$" - 1
  local winwidth = vim.fn.winwidth(0)
  while i <= last do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)
    if #line == 0 then
      break
    end
    local width = vim.fn.strdisplaywidth(line[1])
    count = count + math.ceil(width / winwidth)
    if count >= self.opts.max then
      break
    end
    i = i + 1
  end
  local height = math.max(math.min(count, self.opts.max), self.opts.min)
  vim.api.nvim_win_set_height(0, height)
end

---@param msg string
---@return nil
function Qfheight:warn(msg) --luacheck: ignore 212
  vim.notify("[qfh] " .. msg, vim.log.levels.WARN)
end

return Qfheight
